// lib/presentation/blocs/config/config_event.dart
import 'package:equatable/equatable.dart';

abstract class ConfigEvent extends Equatable {
  const ConfigEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar la configuración médica
class CargarConfiguracionEvent extends ConfigEvent {}

/// Evento para obtener consultorios de un hospital específico
class ObtenerConsultoriosPorHospitalEvent extends ConfigEvent {
  final String codigoHospital;

  const ObtenerConsultoriosPorHospitalEvent(this.codigoHospital);

  @override
  List<Object?> get props => [codigoHospital];
}
