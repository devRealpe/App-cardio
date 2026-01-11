// lib/domain/usecases/config/obtener_focos_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/config/foco_auscultacion.dart';
import '../../repositories/config_repository.dart';

class ObtenerFocosUseCase {
  final ConfigRepository repository;

  ObtenerFocosUseCase({required this.repository});

  Future<Either<Failure, List<FocoAuscultacion>>> call() async {
    final result = await repository.obtenerConfiguracion();
    return result.fold(
      (failure) => Left(failure),
      (config) => Right(config.focos),
    );
  }
}
