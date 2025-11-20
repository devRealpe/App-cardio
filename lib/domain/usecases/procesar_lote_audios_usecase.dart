import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/lote_audios.dart';
import '../entities/formulario_completo.dart';
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
      fechaNacimiento: metadataBase['fechaNacimiento'],
      codigoConsultorio: metadataBase['codigoConsultorio'],
      codigoHospital: metadataBase['codigoHospital'],
      codigoFoco: metadataBase['codigoFoco'],
      observaciones: metadataBase['observaciones'],
    );

    return fileNameResult.fold(
      (failure) => Left(failure),
      (fileName) => repository.enviarFormulario(
        formulario: FormularioCompleto(
          metadata: _crearMetadata(metadataBase, ''),
          fileName: fileName,
        ),
        audioFile: File(audio.path),
      ),
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
        fechaNacimiento: metadataBase['fechaNacimiento'],
        codigoConsultorio: metadataBase['codigoConsultorio'],
        codigoHospital: metadataBase['codigoHospital'],
        codigoFoco: metadataBase['codigoFoco'],
        observaciones: metadataBase['observaciones'],
      );

      final result = await fileNameResult.fold(
        (failure) => Left(failure),
        (fileName) {
          // Insertar sufijo antes de .wav
          final fileNameConSufijo = fileName.replaceAll('.wav', '-$sufijo.wav');

          return repository.enviarFormulario(
            formulario: FormularioCompleto(
              metadata: _crearMetadata(metadataBase, sufijo),
              fileName: fileNameConSufijo,
            ),
            audioFile: File(audio.path),
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

  dynamic _crearMetadata(Map<String, dynamic> base, String sufijo) {
    // Aquí deberías crear tu AudioMetadata con los datos base
    // y el sufijo si es necesario
    return base; // Placeholder
  }
}
