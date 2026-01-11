// lib/presentation/blocs/config/config_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/config/medical_config.dart';
import '../../../domain/entities/config/consultorio.dart';

abstract class ConfigState extends Equatable {
  const ConfigState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ConfigInitial extends ConfigState {}

/// Estado de carga
class ConfigLoading extends ConfigState {}

/// Estado de configuración cargada exitosamente
class ConfigLoaded extends ConfigState {
  final MedicalConfig config;
  final List<Consultorio>? consultoriosFiltrados;

  const ConfigLoaded({
    required this.config,
    this.consultoriosFiltrados,
  });

  @override
  List<Object?> get props => [config, consultoriosFiltrados];

  ConfigLoaded copyWith({
    MedicalConfig? config,
    List<Consultorio>? consultoriosFiltrados,
  }) {
    return ConfigLoaded(
      config: config ?? this.config,
      consultoriosFiltrados:
          consultoriosFiltrados ?? this.consultoriosFiltrados,
    );
  }
}

/// Estado de error
class ConfigError extends ConfigState {
  final String message;

  const ConfigError(this.message);

  @override
  List<Object?> get props => [message];
}
