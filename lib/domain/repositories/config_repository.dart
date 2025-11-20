// lib/domain/repositories/config_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/config/medical_config.dart';
import '../entities/config/consultorio.dart';

abstract class ConfigRepository {
  /// Obtiene la configuración médica completa
  Future<Either<Failure, MedicalConfig>> obtenerConfiguracion();

  /// Obtiene los consultorios de un hospital específico
  Future<Either<Failure, List<Consultorio>>> obtenerConsultoriosPorHospital(
    String codigoHospital,
  );
}
