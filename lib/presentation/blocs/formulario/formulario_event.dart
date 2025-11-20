// lib/presentation/blocs/formulario/formulario_event.dart

import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../data/models/audio_file_wrapper.dart';

abstract class FormularioEvent extends Equatable {
  const FormularioEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para enviar el formulario completo
class EnviarFormularioEvent extends FormularioEvent {
  final DateTime fechaNacimiento;
  final String hospital;
  final String codigoHospital;
  final String consultorio;
  final String codigoConsultorio;
  final String estado;
  final String focoAuscultacion;
  final String codigoFoco;
  final String? observaciones;
  final File? audioFile; // Para móvil (retrocompatibilidad)
  final AudioFileWrapper? audioFileWrapper; // Para web y móvil

  const EnviarFormularioEvent({
    required this.fechaNacimiento,
    required this.hospital,
    required this.codigoHospital,
    required this.consultorio,
    required this.codigoConsultorio,
    required this.estado,
    required this.focoAuscultacion,
    required this.codigoFoco,
    this.observaciones,
    this.audioFile,
    this.audioFileWrapper,
  });

  @override
  List<Object?> get props => [
        fechaNacimiento,
        hospital,
        codigoHospital,
        consultorio,
        codigoConsultorio,
        estado,
        focoAuscultacion,
        codigoFoco,
        observaciones,
        audioFile,
        audioFileWrapper,
      ];
}

/// Evento para resetear el formulario después de envío exitoso
class ResetFormularioEvent extends FormularioEvent {}
