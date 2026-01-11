// lib/domain/usecases/enviar_formulario_usecase.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/formulario_completo.dart';
import '../repositories/formulario_repository.dart';

/// Caso de uso para enviar un formulario completo
class EnviarFormularioUseCase {
  final FormularioRepository repository;

  EnviarFormularioUseCase({required this.repository});

  /// Ejecuta el caso de uso
  ///
  /// [formulario] El formulario completo a enviar
  /// [audioFile] El archivo de audio físico
  /// [onProgress] Callback opcional para reportar progreso
  Future<Either<Failure, void>> call({
    required FormularioCompleto formulario,
    required File audioFile,
    void Function(double progress, String status)? onProgress,
  }) async {
    return await repository.enviarFormulario(
      formulario: formulario,
      audioFile: audioFile,
      onProgress: onProgress,
    );
  }
}
