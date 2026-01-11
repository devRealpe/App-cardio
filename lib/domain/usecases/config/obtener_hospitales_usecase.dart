// lib/domain/usecases/config/obtener_hospitales_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/config/hospital.dart';
import '../../repositories/config_repository.dart';

class ObtenerHospitalesUseCase {
  final ConfigRepository repository;

  ObtenerHospitalesUseCase({required this.repository});

  Future<Either<Failure, List<Hospital>>> call() async {
    final result = await repository.obtenerConfiguracion();
    return result.fold(
      (failure) => Left(failure),
      (config) => Right(config.hospitales),
    );
  }
}
