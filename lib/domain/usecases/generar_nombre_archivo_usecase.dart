// lib/domain/usecases/generar_nombre_archivo_usecase.dart

import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/formulario_repository.dart';

/// Caso de uso para generar el nombre de archivo siguiendo la nomenclatura
class GenerarNombreArchivoUseCase {
  final FormularioRepository repository;

  GenerarNombreArchivoUseCase({required this.repository});

  /// Ejecuta el caso de uso
  ///
  /// Formato: DDMMAA-CCHH-FF-AAAA-EEOO.wav
  /// DD: día, MM: mes, AA: año
  /// CC: código consultorio, HH: código hospital
  /// FF: código foco
  /// AAAA: ID audio (con padding)
  /// EE: edad, OO: tiene observaciones (01/00)
  Future<Either<Failure, String>> call({
    required DateTime fechaNacimiento,
    required String codigoConsultorio,
    required String codigoHospital,
    required String codigoFoco,
    String? observaciones, // CORRECCIÓN: opcional
  }) async {
    return await repository.generarNombreArchivo(
      fechaNacimiento: fechaNacimiento,
      codigoConsultorio: codigoConsultorio,
      codigoHospital: codigoHospital,
      codigoFoco: codigoFoco,
      observaciones: observaciones,
    );
  }
}
