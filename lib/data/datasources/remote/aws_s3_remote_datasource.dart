// lib/data/datasources/remote/aws_s3_remote_datasource.dart
// VERSIÓN MEJORADA con timeouts, reintentos y mejor manejo de errores

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart'
    hide StorageException, NetworkException;
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';

/// Contrato para el data source remoto de AWS S3
abstract class AwsS3RemoteDataSource {
  Future<String> subirAudio({
    required File audioFile,
    required String fileName,
    void Function(double progress)? onProgress,
  });

  Future<void> subirMetadata({
    required Map<String, dynamic> metadata,
    required String fileName,
    void Function(double progress)? onProgress,
  });

  Future<String> obtenerSiguienteAudioId();
}

/// Implementación del data source remoto usando AWS Amplify S3
class AwsS3RemoteDataSourceImpl implements AwsS3RemoteDataSource {
  // Configuración de reintentos
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  // Timeouts
  static const Duration _uploadTimeout = Duration(minutes: 5);
  static const Duration _listTimeout = Duration(seconds: 30);

  @override
  Future<String> subirAudio({
    required File audioFile,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    return await _executeWithRetry(
      operation: () => _uploadAudioOperation(audioFile, fileName, onProgress),
      operationName: 'subir audio',
    );
  }

  @override
  Future<void> subirMetadata({
    required Map<String, dynamic> metadata,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    return await _executeWithRetry(
      operation: () => _uploadMetadataOperation(metadata, fileName, onProgress),
      operationName: 'subir metadata',
    );
  }

  @override
  Future<String> obtenerSiguienteAudioId() async {
    return await _executeWithRetry(
      operation: _obtenerSiguienteAudioIdOperation,
      operationName: 'obtener ID de audio',
      maxRetries: 2, // Menos reintentos para operaciones de lectura
    );
  }

  /// Ejecuta una operación con estrategia de reintentos
  Future<T> _executeWithRetry<T>({
    required Future<T> Function() operation,
    required String operationName,
    int maxRetries = _maxRetries,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } on SocketException {
        attempts++;
        if (attempts >= maxRetries) {
          throw NetworkException(
            'Sin conexión a Internet al $operationName. Verifica tu conexión.',
          );
        }
        await Future.delayed(_retryDelay * attempts);
      } on TimeoutException {
        attempts++;
        if (attempts >= maxRetries) {
          throw NetworkException(
            'Tiempo de espera agotado al $operationName. La conexión es muy lenta.',
          );
        }
        await Future.delayed(_retryDelay * attempts);
      } on AmplifyException catch (e) {
        // Analizar el tipo de error de Amplify
        if (_isNetworkError(e)) {
          attempts++;
          if (attempts >= maxRetries) {
            throw NetworkException(
              'Error de red al $operationName: ${e.message}',
            );
          }
          await Future.delayed(_retryDelay * attempts);
        } else if (_isAuthError(e)) {
          // No reintentar errores de autenticación
          throw StorageException(
            'Error de autenticación al $operationName: ${e.message}',
          );
        } else if (_isStorageError(e)) {
          // No reintentar errores de almacenamiento (archivo no existe, etc.)
          throw StorageException(
            'Error de almacenamiento al $operationName: ${e.message}',
          );
        } else {
          throw StorageException(
            'Error al $operationName: ${e.message}',
          );
        }
      } catch (e) {
        throw StorageException(
          'Error inesperado al $operationName: $e',
        );
      }
    }

    throw NetworkException('Máximo de reintentos alcanzado al $operationName');
  }

  /// Operación real de subida de audio
  Future<String> _uploadAudioOperation(
    File audioFile,
    String fileName,
    void Function(double progress)? onProgress,
  ) async {
    // Validar que el archivo existe
    if (!audioFile.existsSync()) {
      throw const FileException('El archivo de audio no existe');
    }

    // Validar tamaño del archivo
    final fileSize = audioFile.lengthSync();
    final fileSizeMB = fileSize / (1024 * 1024);
    if (fileSizeMB > AppConstants.maxAudioFileSizeMB) {
      throw FileException(
        'El archivo es demasiado grande (${fileSizeMB.toStringAsFixed(1)} MB). '
        'Máximo permitido: ${AppConstants.maxAudioFileSizeMB} MB',
      );
    }

    // Ruta en S3
    final s3Path = '${AppConstants.s3AudioPrefix}$fileName';

    // Subir archivo con timeout
    final uploadOperation = Amplify.Storage.uploadFile(
      localFile: AWSFile.fromPath(audioFile.path),
      path: StoragePath.fromString(s3Path),
      onProgress: (uploadProgress) {
        final fraction =
            uploadProgress.transferredBytes / uploadProgress.totalBytes;
        onProgress?.call(fraction);
      },
    );

    // Aplicar timeout
    await uploadOperation.result.timeout(
      _uploadTimeout,
      onTimeout: () {
        throw TimeoutException(
          'Tiempo de espera agotado al subir audio',
          _uploadTimeout,
        );
      },
    );

    // Construir URL pública
    final audioUrl =
        'https://${AppConstants.s3BucketName}.s3.${AppConstants.s3Region}.amazonaws.com/$s3Path';

    return audioUrl;
  }

  /// Operación real de subida de metadata
  Future<void> _uploadMetadataOperation(
    Map<String, dynamic> metadata,
    String fileName,
    void Function(double progress)? onProgress,
  ) async {
    // Crear archivo JSON temporal
    final jsonFile = await _createTempJsonFile(metadata, fileName);

    try {
      // Ruta en S3 (sin extensión .wav, agregamos .json)
      final fileNameWithoutExt = fileName.replaceAll('.wav', '');
      final s3Path = '${AppConstants.s3JsonPrefix}$fileNameWithoutExt.json';

      // Subir archivo JSON con timeout
      final uploadOperation = Amplify.Storage.uploadFile(
        localFile: AWSFile.fromPath(jsonFile.path),
        path: StoragePath.fromString(s3Path),
        onProgress: (uploadProgress) {
          final fraction =
              uploadProgress.transferredBytes / uploadProgress.totalBytes;
          onProgress?.call(fraction);
        },
      );

      await uploadOperation.result.timeout(
        _uploadTimeout,
        onTimeout: () {
          throw TimeoutException(
            'Tiempo de espera agotado al subir metadata',
            _uploadTimeout,
          );
        },
      );
    } finally {
      // Eliminar archivo temporal siempre
      if (await jsonFile.exists()) {
        await jsonFile.delete();
      }
    }
  }

  /// Operación real de obtener siguiente ID
  Future<String> _obtenerSiguienteAudioIdOperation() async {
    // Listar archivos en la carpeta de audios con timeout
    final result = await Amplify.Storage.list(
      path: StoragePath.fromString(AppConstants.s3AudioPrefix),
      options: const StorageListOptions(
        pageSize: 1000,
      ),
    ).result.timeout(
      _listTimeout,
      onTimeout: () {
        throw TimeoutException(
          'Tiempo de espera agotado al listar archivos',
          _listTimeout,
        );
      },
    );

    // Contar archivos y calcular siguiente ID
    final count = result.items.length;
    final nextId = count + 1;

    // Formatear con padding según configuración
    return nextId.toString().padLeft(AppConstants.audioIdPadding, '0');
  }

  /// Crea un archivo JSON temporal
  Future<File> _createTempJsonFile(
    Map<String, dynamic> jsonData,
    String fileName,
  ) async {
    try {
      final dir = await getTemporaryDirectory();
      final fileNameWithoutExt = fileName.replaceAll('.wav', '');
      final file = File('${dir.path}/$fileNameWithoutExt.json');

      await file.writeAsString(
        jsonEncode(jsonData),
        flush: true,
      );

      return file;
    } catch (e) {
      throw FileException('Error al crear archivo JSON temporal: $e');
    }
  }

  /// Determina si un error de Amplify es de red
  bool _isNetworkError(AmplifyException e) {
    final message = e.message.toLowerCase();
    return message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('unreachable') ||
        message.contains('socket');
  }

  /// Determina si un error de Amplify es de autenticación
  bool _isAuthError(AmplifyException e) {
    final message = e.message.toLowerCase();
    return message.contains('auth') ||
        message.contains('credential') ||
        message.contains('permission') ||
        message.contains('unauthorized');
  }

  /// Determina si un error de Amplify es de almacenamiento
  bool _isStorageError(AmplifyException e) {
    final message = e.message.toLowerCase();
    return message.contains('not found') ||
        message.contains('does not exist') ||
        message.contains('no such key');
  }
}
