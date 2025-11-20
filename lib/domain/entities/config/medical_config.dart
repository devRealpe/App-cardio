import 'package:equatable/equatable.dart';
import 'hospital.dart';
import 'consultorio.dart';
import 'foco_auscultacion.dart';

class MedicalConfig extends Equatable {
  final List<Hospital> hospitales;
  final List<Consultorio> consultorios;
  final List<FocoAuscultacion> focos;

  const MedicalConfig({
    required this.hospitales,
    required this.consultorios,
    required this.focos,
  });

  /// Obtiene los consultorios de un hospital específico
  List<Consultorio> getConsultoriosPorHospital(String codigoHospital) {
    return consultorios
        .where((c) => c.codigoHospital == codigoHospital)
        .toList();
  }

  /// Obtiene un hospital por su nombre
  Hospital? getHospitalPorNombre(String nombre) {
    try {
      return hospitales.firstWhere((h) => h.nombre == nombre);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene un consultorio por su nombre
  Consultorio? getConsultorioPorNombre(String nombre) {
    try {
      return consultorios.firstWhere((c) => c.nombre == nombre);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene un foco por su nombre
  FocoAuscultacion? getFocoPorNombre(String nombre) {
    try {
      return focos.firstWhere((f) => f.nombre == nombre);
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [hospitales, consultorios, focos];
}
