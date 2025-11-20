// lib/domain/usecases/config/obtener_consultorios_por_hospital_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/config/consultorio.dart';
import '../../repositories/config_repository.dart';

class ObtenerConsultoriosPorHospitalUseCase {
  final ConfigRepository repository;

  ObtenerConsultoriosPorHospitalUseCase({required this.repository});

  Future<Either<Failure, List<Consultorio>>> call(String codigoHospital) async {
    return await repository.obtenerConsultoriosPorHospital(codigoHospital);
  }
}
