// lib/domain/repositories/formulario_repository.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/formulario_completo.dart';

abstract class FormularioRepository {
  /// Envía un formulario completo con audio a S3
  Future<Either<Failure, void>> enviarFormulario({
    required FormularioCompleto formulario,
    required File audioFile,
    void Function(double progress, String status)? onProgress,
  });

  /// Genera el nombre de archivo siguiendo la nomenclatura establecida
  Future<Either<Failure, String>> generarNombreArchivo({
    required DateTime fechaNacimiento,
    required String codigoConsultorio,
    required String codigoHospital,
    required String codigoFoco,
    String? observaciones,
  });
}
