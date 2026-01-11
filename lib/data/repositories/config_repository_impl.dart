// lib/data/repositories/config_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/config/medical_config.dart';
import '../../domain/entities/config/consultorio.dart';
import '../../domain/repositories/config_repository.dart';
import '../datasources/local/config_local_datasource.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  final ConfigLocalDataSource localDataSource;

  // Cache de la configuración para evitar múltiples lecturas
  MedicalConfig? _cachedConfig;

  ConfigRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, MedicalConfig>> obtenerConfiguracion() async {
    // Si ya tenemos la configuración en caché, la retornamos
    if (_cachedConfig != null) {
      return Right(_cachedConfig!);
    }

    try {
      final config = await localDataSource.obtenerConfiguracion();
      _cachedConfig = config;
      return Right(config);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Consultorio>>> obtenerConsultoriosPorHospital(
    String codigoHospital,
  ) async {
    try {
      // Primero obtenemos la configuración
      final configResult = await obtenerConfiguracion();

      return configResult.fold(
        (failure) => Left(failure),
        (config) {
          // Filtramos los consultorios del hospital específico
          final consultorios = config.consultorios
              .where((c) => c.codigoHospital == codigoHospital)
              .toList();

          if (consultorios.isEmpty) {
            return Left(
              CacheFailure('No se encontraron consultorios para el hospital'),
            );
          }

          return Right(consultorios);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
