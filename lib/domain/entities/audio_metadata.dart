// lib/domain/entities/audio_metadata.dart

import 'package:equatable/equatable.dart';

/// Entidad que representa los metadatos de un audio cardíaco
class AudioMetadata extends Equatable {
  // Información temporal
  final DateTime fechaNacimiento;
  final int edad;
  final DateTime fechaGrabacion;
  final String urlAudio;

  // Información de ubicación
  final String hospital;
  final String codigoHospital;
  final String consultorio;
  final String codigoConsultorio;

  // Información médica
  final String estado;
  final String focoAuscultacion;
  final String codigoFoco;
  final String? observaciones;

  const AudioMetadata({
    required this.fechaNacimiento,
    required this.edad,
    required this.fechaGrabacion,
    required this.urlAudio,
    required this.hospital,
    required this.codigoHospital,
    required this.consultorio,
    required this.codigoConsultorio,
    required this.estado,
    required this.focoAuscultacion,
    required this.codigoFoco,
    this.observaciones,
  });

  @override
  List<Object?> get props => [
        fechaNacimiento,
        edad,
        fechaGrabacion,
        urlAudio,
        hospital,
        codigoHospital,
        consultorio,
        codigoConsultorio,
        estado,
        focoAuscultacion,
        codigoFoco,
        observaciones,
      ];
}
