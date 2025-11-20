// lib/presentation/blocs/formulario/formulario_state.dart

import 'package:equatable/equatable.dart';

abstract class FormularioState extends Equatable {
  const FormularioState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial del formulario
class FormularioInitial extends FormularioState {}

/// Estado mientras se está enviando el formulario
class FormularioEnviando extends FormularioState {
  final double progress;
  final String status;

  const FormularioEnviando({
    required this.progress,
    required this.status,
  });

  @override
  List<Object?> get props => [progress, status];
}

/// Estado cuando el formulario se envió exitosamente
class FormularioEnviadoExitosamente extends FormularioState {
  final String mensaje;

  const FormularioEnviadoExitosamente({
    this.mensaje = 'Formulario enviado exitosamente',
  });

  @override
  List<Object?> get props => [mensaje];
}

/// Estado de error al enviar el formulario
class FormularioError extends FormularioState {
  final String mensaje;

  const FormularioError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}
