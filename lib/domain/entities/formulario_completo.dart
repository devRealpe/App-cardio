// lib/domain/entities/formulario_completo.dart

import 'package:equatable/equatable.dart';
import 'audio_metadata.dart';

/// Entidad que representa un formulario completo con audio
class FormularioCompleto extends Equatable {
  final AudioMetadata metadata;
  final String fileName;

  const FormularioCompleto({
    required this.metadata,
    required this.fileName,
  });

  @override
  List<Object?> get props => [metadata, fileName];
}
