// lib/data/models/formulario_completo_model.dart

import '../../domain/entities/formulario_completo.dart';
import 'audio_metadata_model.dart';

/// Modelo de datos para FormularioCompleto
class FormularioCompletoModel extends FormularioCompleto {
  const FormularioCompletoModel({
    required super.metadata,
    required super.fileName,
  });

  /// Crea un modelo desde JSON
  factory FormularioCompletoModel.fromJson(Map<String, dynamic> json) {
    return FormularioCompletoModel(
      metadata: AudioMetadataModel.fromJson(json),
      fileName: json['file_name'] as String,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    final metadataJson = (metadata as AudioMetadataModel).toJson();
    return {
      ...metadataJson,
      'file_name': fileName,
    };
  }

  /// Crea una copia del modelo con campos actualizados
  FormularioCompletoModel copyWith({
    AudioMetadataModel? metadata,
    String? fileName,
  }) {
    return FormularioCompletoModel(
      metadata: metadata ?? this.metadata,
      fileName: fileName ?? this.fileName,
    );
  }
}
