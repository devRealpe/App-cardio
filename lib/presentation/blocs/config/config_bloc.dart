// lib/presentation/blocs/config/config_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/config_repository.dart';
import '../../../domain/usecases/config/obtener_consultorios_por_hospital_usecase.dart';
import 'config_event.dart';
import 'config_state.dart';

class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  final ConfigRepository configRepository;
  final ObtenerConsultoriosPorHospitalUseCase obtenerConsultoriosUseCase;

  ConfigBloc({
    required this.configRepository,
    required this.obtenerConsultoriosUseCase,
  }) : super(ConfigInitial()) {
    on<CargarConfiguracionEvent>(_onCargarConfiguracion);
    on<ObtenerConsultoriosPorHospitalEvent>(_onObtenerConsultoriosPorHospital);
  }

  Future<void> _onCargarConfiguracion(
    CargarConfiguracionEvent event,
    Emitter<ConfigState> emit,
  ) async {
    emit(ConfigLoading());

    final result = await configRepository.obtenerConfiguracion();

    result.fold(
      (failure) => emit(ConfigError(failure.message)),
      (config) => emit(ConfigLoaded(config: config)),
    );
  }

  Future<void> _onObtenerConsultoriosPorHospital(
    ObtenerConsultoriosPorHospitalEvent event,
    Emitter<ConfigState> emit,
  ) async {
    // Mantener el estado actual mientras se cargan los consultorios
    if (state is ConfigLoaded) {
      final currentState = state as ConfigLoaded;

      final result = await obtenerConsultoriosUseCase(event.codigoHospital);

      result.fold(
        (failure) => emit(ConfigError(failure.message)),
        (consultorios) => emit(
          currentState.copyWith(consultoriosFiltrados: consultorios),
        ),
      );
    }
  }
}
