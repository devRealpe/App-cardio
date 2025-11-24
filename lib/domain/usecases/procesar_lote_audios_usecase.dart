// lib/domain/usecases/procesar_lote_audios_usecase.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../data/models/audio_file_wrapper.dart';
import '../entities/lote_audios.dart';
import '../entities/formulario_completo.dart';
import '../entities/audio_metadata.dart';
import '../repositories/formulario_repository.dart';

class ProcesarLoteAudiosUseCase {
  final FormularioRepository repository;

  ProcesarLoteAudiosUseCase({required this.repository});

  /// Procesa un lote de audios, agregando sufijos secuenciales si es necesario
  Future<Either<Failure, void>> call({
    required LoteAudios lote,
    required Map<String, dynamic> metadataBase,
    void Function(int actual, int total, String status)? onProgress,
  }) async {
    // Si solo hay un audio, no agregar sufijo
    if (lote.cantidadAudios == 1) {
      return _procesarAudioUnico(
        audio: lote.audios.first,
        metadataBase: metadataBase,
        onProgress: onProgress,
      );
    }

    // Procesar múltiples audios con sufijos
    return _procesarMultiplesAudios(
      lote: lote,
      metadataBase: metadataBase,
      onProgress: onProgress,
    );
  }

  Future<Either<Failure, void>> _procesarAudioUnico({
    required AudioParaProcesar audio,
    required Map<String, dynamic> metadataBase,
    void Function(int actual, int total, String status)? onProgress,
  }) async {
    onProgress?.call(1, 1, 'Procesando audio único...');

    // Generar nombre de archivo sin sufijo
    final fileNameResult = await repository.generarNombreArchivo(
      fechaNacimiento: metadataBase['fechaNacimiento'] as DateTime,
      codigoConsultorio: metadataBase['codigoConsultorio'] as String,
      codigoHospital: metadataBase['codigoHospital'] as String,
      codigoFoco: metadataBase['codigoFoco'] as String,
      observaciones: metadataBase['observaciones'] as String?,
    );

    return fileNameResult.fold(
      (failure) => Left(failure),
      (fileName) async {
        // Crear wrapper del archivo
        final audioFile = AudioFileWrapper(
          filePath: audio.path,
          fileName: audio.nombre,
          size: await File(audio.path).length(),
        );

        // Crear metadata
        final metadata = _crearMetadata(metadataBase, '');

        // Crear formulario
        final formulario = FormularioCompleto(
          metadata: metadata,
          fileName: fileName,
        );

        // Enviar formulario
        return repository.enviarFormulario(
          formulario: formulario,
          audioFile: audioFile,
        );
      },
    );
  }

  Future<Either<Failure, void>> _procesarMultiplesAudios({
    required LoteAudios lote,
    required Map<String, dynamic> metadataBase,
    void Function(int actual, int total, String status)? onProgress,
  }) async {
    for (int i = 0; i < lote.audios.length; i++) {
      final audio = lote.audios[i];
      final sufijo = audio.sufijo;

      onProgress?.call(
        i + 1,
        lote.cantidadAudios,
        'Procesando audio ${i + 1}/${lote.cantidadAudios}',
      );

      // Generar nombre de archivo con sufijo
      final fileNameResult = await repository.generarNombreArchivo(
        fechaNacimiento: metadataBase['fechaNacimiento'] as DateTime,
        codigoConsultorio: metadataBase['codigoConsultorio'] as String,
        codigoHospital: metadataBase['codigoHospital'] as String,
        codigoFoco: metadataBase['codigoFoco'] as String,
        observaciones: metadataBase['observaciones'] as String?,
      );

      final result = await fileNameResult.fold(
        (failure) async => Left<Failure, void>(failure),
        (fileName) async {
          // Insertar sufijo antes de .wav
          final fileNameConSufijo = fileName.replaceAll('.wav', '-$sufijo.wav');

          // Crear wrapper del archivo
          final audioFile = AudioFileWrapper(
            filePath: audio.path,
            fileName: audio.nombre,
            size: await File(audio.path).length(),
          );

          // Crear metadata
          final metadata = _crearMetadata(metadataBase, sufijo);

          // Crear formulario
          final formulario = FormularioCompleto(
            metadata: metadata,
            fileName: fileNameConSufijo,
          );

          // Enviar formulario
          return repository.enviarFormulario(
            formulario: formulario,
            audioFile: audioFile,
          );
        },
      );

      // Si hay error en algún audio, detener el proceso
      if (result.isLeft()) {
        return result;
      }
    }

    return const Right(null);
  }

  AudioMetadata _crearMetadata(Map<String, dynamic> base, String sufijo) {
    final fechaNacimiento = base['fechaNacimiento'] as DateTime;
    final edad = DateTime.now().difference(fechaNacimiento).inDays ~/ 365;

    return AudioMetadata(
      fechaNacimiento: fechaNacimiento,
      edad: edad,
      fechaGrabacion: DateTime.now(),
      urlAudio: '', // Se actualizará después de subir
      hospital: base['hospital'] as String,
      codigoHospital: base['codigoHospital'] as String,
      consultorio: base['consultorio'] as String,
      codigoConsultorio: base['codigoConsultorio'] as String,
      estado: base['estado'] as String,
      focoAuscultacion: base['focoAuscultacion'] as String,
      codigoFoco: base['codigoFoco'] as String,
      observaciones: base['observaciones'] as String?,
    );
  }
}
