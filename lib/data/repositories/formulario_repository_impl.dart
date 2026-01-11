// lib/data/repositories/formulario_repository_impl.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/formulario_completo.dart';
import '../../domain/repositories/formulario_repository.dart';
import '../datasources/remote/aws_s3_remote_datasource.dart';
import '../models/audio_metadata_model.dart';

class FormularioRepositoryImpl implements FormularioRepository {
  final AwsS3RemoteDataSource remoteDataSource;

  FormularioRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> enviarFormulario({
    required FormularioCompleto formulario,
    required File audioFile,
    void Function(double progress, String status)? onProgress,
  }) async {
    try {
      // 1. Subir archivo de audio
      onProgress?.call(0.0, 'Subiendo archivo de audio...');

      final audioUrl = await remoteDataSource.subirAudio(
        audioFile: audioFile,
        fileName: formulario.fileName,
        onProgress: (progress) {
          onProgress?.call(progress * 0.5, 'Subiendo archivo de audio...');
        },
      );

      onProgress?.call(0.5, 'Archivo de audio subido exitosamente');

      // 2. Actualizar metadata con la URL del audio
      final metadataModel = AudioMetadataModel(
        fechaNacimiento: formulario.metadata.fechaNacimiento,
        edad: formulario.metadata.edad,
        fechaGrabacion: formulario.metadata.fechaGrabacion,
        urlAudio: audioUrl,
        hospital: formulario.metadata.hospital,
        codigoHospital: formulario.metadata.codigoHospital,
        consultorio: formulario.metadata.consultorio,
        codigoConsultorio: formulario.metadata.codigoConsultorio,
        estado: formulario.metadata.estado,
        focoAuscultacion: formulario.metadata.focoAuscultacion,
        codigoFoco: formulario.metadata.codigoFoco,
        observaciones: formulario.metadata.observaciones,
      );

      // 3. Subir archivo JSON con metadata
      onProgress?.call(0.5, 'Subiendo metadatos...');

      await remoteDataSource.subirMetadata(
        metadata: metadataModel.toJson(),
        fileName: formulario.fileName,
        onProgress: (progress) {
          onProgress?.call(0.5 + progress * 0.5, 'Subiendo metadatos...');
        },
      );

      onProgress?.call(1.0, 'Formulario enviado exitosamente');

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> generarNombreArchivo({
    required DateTime fechaNacimiento,
    required String codigoConsultorio,
    required String codigoHospital,
    required String codigoFoco,
    String? observaciones, // CORRECCIÓN: opcional en lugar de requerido
  }) async {
    try {
      final ahora = DateTime.now();
      final edad = ahora.difference(fechaNacimiento).inDays ~/ 365;

      String twoDigits(int n) => n.toString().padLeft(2, '0');

      final dia = twoDigits(ahora.day);
      final mes = twoDigits(ahora.month);
      final anio = twoDigits(ahora.year % 100);

      // Obtener siguiente ID de audio
      final audioId = await remoteDataSource.obtenerSiguienteAudioId();

      final edadStr = twoDigits(edad);
      final obsStr = (observaciones?.isNotEmpty ?? false) ? '01' : '00';

      // Formato: DDMMAA-CCHH-FF-AAAA-EEOO.wav
      final fileName =
          '$dia$mes$anio-$codigoConsultorio$codigoHospital-$codigoFoco-$audioId-$edadStr$obsStr.wav';

      return Right(fileName);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
