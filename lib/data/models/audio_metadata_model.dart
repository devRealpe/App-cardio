// lib/data/models/audio_metadata_model.dart

import '../../domain/entities/audio_metadata.dart';

/// Modelo de datos para AudioMetadata con serialización JSON
class AudioMetadataModel extends AudioMetadata {
  const AudioMetadataModel({
    required super.fechaNacimiento,
    required super.edad,
    required super.fechaGrabacion,
    required super.urlAudio,
    required super.hospital,
    required super.codigoHospital,
    required super.consultorio,
    required super.codigoConsultorio,
    required super.estado,
    required super.focoAuscultacion,
    required super.codigoFoco,
    super.observaciones,
  });

  /// Crea un modelo desde JSON
  factory AudioMetadataModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map<String, dynamic>;
    final ubicacion = json['ubicacion'] as Map<String, dynamic>;
    final diagnostico = json['diagnostico'] as Map<String, dynamic>;

    return AudioMetadataModel(
      fechaNacimiento: DateTime.parse(metadata['fecha_nacimiento'] as String),
      edad: metadata['edad'] as int,
      fechaGrabacion: DateTime.parse(metadata['fecha_grabacion'] as String),
      urlAudio: metadata['url_audio'] as String,
      hospital: ubicacion['hospital'] as String,
      codigoHospital: ubicacion['codigo_hospital'] as String,
      consultorio: ubicacion['consultorio'] as String,
      codigoConsultorio: ubicacion['codigo_consultorio'] as String,
      estado: diagnostico['estado'] as String,
      focoAuscultacion: diagnostico['foco_auscultacion'] as String,
      codigoFoco: diagnostico['codigo_foco'] as String,
      observaciones: diagnostico['observaciones'] as String?,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'metadata': {
        'fecha_nacimiento': fechaNacimiento.toIso8601String(),
        'edad': edad,
        'fecha_grabacion': fechaGrabacion.toIso8601String(),
        'url_audio': urlAudio,
      },
      'ubicacion': {
        'hospital': hospital,
        'codigo_hospital': codigoHospital,
        'consultorio': consultorio,
        'codigo_consultorio': codigoConsultorio,
      },
      'diagnostico': {
        'estado': estado,
        'foco_auscultacion': focoAuscultacion,
        'codigo_foco': codigoFoco,
        'observaciones': observaciones ?? 'No aplica',
      },
    };
  }

  /// Crea una copia del modelo con campos actualizados
  AudioMetadataModel copyWith({
    DateTime? fechaNacimiento,
    int? edad,
    DateTime? fechaGrabacion,
    String? urlAudio,
    String? hospital,
    String? codigoHospital,
    String? consultorio,
    String? codigoConsultorio,
    String? estado,
    String? focoAuscultacion,
    String? codigoFoco,
    String? observaciones,
  }) {
    return AudioMetadataModel(
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      edad: edad ?? this.edad,
      fechaGrabacion: fechaGrabacion ?? this.fechaGrabacion,
      urlAudio: urlAudio ?? this.urlAudio,
      hospital: hospital ?? this.hospital,
      codigoHospital: codigoHospital ?? this.codigoHospital,
      consultorio: consultorio ?? this.consultorio,
      codigoConsultorio: codigoConsultorio ?? this.codigoConsultorio,
      estado: estado ?? this.estado,
      focoAuscultacion: focoAuscultacion ?? this.focoAuscultacion,
      codigoFoco: codigoFoco ?? this.codigoFoco,
      observaciones: observaciones ?? this.observaciones,
    );
  }
}
