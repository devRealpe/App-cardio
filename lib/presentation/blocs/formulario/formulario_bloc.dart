// lib/presentation/blocs/formulario/formulario_bloc.dart
// VERSIÓN MEJORADA con soporte WEB

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/network_info.dart';
import '../../../domain/entities/audio_metadata.dart';
import '../../../domain/entities/formulario_completo.dart';
import '../../../domain/usecases/enviar_formulario_usecase.dart';
import '../../../domain/usecases/generar_nombre_archivo_usecase.dart';
import 'formulario_event.dart';
import 'formulario_state.dart';

class FormularioBloc extends Bloc<FormularioEvent, FormularioState> {
  final EnviarFormularioUseCase enviarFormularioUseCase;
  final GenerarNombreArchivoUseCase generarNombreArchivoUseCase;
  final NetworkInfo networkInfo;

  FormularioBloc({
    required this.enviarFormularioUseCase,
    required this.generarNombreArchivoUseCase,
    required this.networkInfo,
  }) : super(FormularioInitial()) {
    on<EnviarFormularioEvent>(_onEnviarFormulario);
    on<ResetFormularioEvent>(_onResetFormulario);
  }

  Future<void> _onEnviarFormulario(
    EnviarFormularioEvent event,
    Emitter<FormularioState> emit,
  ) async {
    // 1. Verificar conectividad REAL antes de iniciar
    emit(const FormularioEnviando(
      progress: 0.0,
      status: 'Verificando conexión a Internet...',
    ));

    final hasConnection = await networkInfo.isConnected;

    if (!hasConnection) {
      emit(const FormularioError(
        mensaje: 'No hay conexión a Internet. Por favor, verifica:\n'
            '• Que estés conectado a WiFi o datos móviles\n'
            '• Que tu conexión tenga acceso a Internet\n'
            '• Que no estés en modo avión',
      ));
      return;
    }

    // 2. Verificar calidad de conexión
    final quality = await networkInfo.connectionQuality;

    if (quality == ConnectionQuality.veryPoor) {
      emit(const FormularioEnviando(
        progress: 0.0,
        status:
            'Conexión detectada pero es muy lenta. Esto puede tomar tiempo...',
      ));
      await Future.delayed(const Duration(seconds: 2));
    } else if (quality == ConnectionQuality.poor) {
      emit(const FormularioEnviando(
        progress: 0.0,
        status: 'Conexión lenta detectada. Ten paciencia...',
      ));
      await Future.delayed(const Duration(seconds: 1));
    }

    // 3. Verificar que tenemos el archivo (wrapper)
    final audioWrapper = event.audioFileWrapper;
    if (audioWrapper == null || !audioWrapper.isValid) {
      emit(const FormularioError(
        mensaje: 'El archivo de audio no es válido o no se pudo cargar',
      ));
      return;
    }

    // 4. Generar nombre de archivo
    emit(const FormularioEnviando(
      progress: 0.05,
      status: 'Generando nombre de archivo...',
    ));

    final nombreArchivoResult = await generarNombreArchivoUseCase(
      fechaNacimiento: event.fechaNacimiento,
      codigoConsultorio: event.codigoConsultorio,
      codigoHospital: event.codigoHospital,
      codigoFoco: event.codigoFoco,
      observaciones: event.observaciones,
    );

    await nombreArchivoResult.fold(
      (failure) async {
        emit(FormularioError(mensaje: failure.message));
      },
      (fileName) async {
        // 5. Calcular edad
        final edad =
            DateTime.now().difference(event.fechaNacimiento).inDays ~/ 365;

        // 6. Crear metadata
        final metadata = AudioMetadata(
          fechaNacimiento: event.fechaNacimiento,
          edad: edad,
          fechaGrabacion: DateTime.now(),
          urlAudio: '', // Se actualizará después de subir el audio
          hospital: event.hospital,
          codigoHospital: event.codigoHospital,
          consultorio: event.consultorio,
          codigoConsultorio: event.codigoConsultorio,
          estado: event.estado,
          focoAuscultacion: event.focoAuscultacion,
          codigoFoco: event.codigoFoco,
          observaciones: event.observaciones,
        );

        // 7. Crear formulario completo
        final formulario = FormularioCompleto(
          metadata: metadata,
          fileName: fileName,
        );

        // 8. Enviar formulario usando el wrapper
        final result = await enviarFormularioUseCase(
          formulario: formulario,
          audioFile: audioWrapper,
          onProgress: (progress, status) {
            emit(FormularioEnviando(
              progress: 0.05 + (progress * 0.95),
              status: status,
            ));
          },
        );

        // 9. Emitir resultado final
        result.fold(
          (failure) {
            String errorMessage = failure.message;

            if (failure.message.toLowerCase().contains('conexión') ||
                failure.message.toLowerCase().contains('network')) {
              errorMessage = 'Error de conexión:\n${failure.message}\n\n'
                  'Sugerencias:\n'
                  '• Verifica tu conexión a Internet\n'
                  '• Intenta acercarte a tu router WiFi\n'
                  '• Si usas datos móviles, verifica tu señal';
            } else if (failure.message.toLowerCase().contains('tiempo')) {
              errorMessage =
                  'La operación tomó demasiado tiempo:\n${failure.message}\n\n'
                  'Tu conexión puede ser muy lenta. Intenta:\n'
                  '• Conectarte a una red WiFi más rápida\n'
                  '• Verificar que no haya otras descargas activas\n'
                  '• Intentar nuevamente más tarde';
            }

            emit(FormularioError(mensaje: errorMessage));
          },
          (_) => emit(const FormularioEnviadoExitosamente()),
        );
      },
    );
  }

  void _onResetFormulario(
    ResetFormularioEvent event,
    Emitter<FormularioState> emit,
  ) {
    emit(FormularioInitial());
  }
}
