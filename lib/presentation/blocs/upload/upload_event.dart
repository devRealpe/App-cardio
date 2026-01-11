// lib/presentation/blocs/upload/upload_event.dart

import 'package:equatable/equatable.dart';

abstract class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para actualizar el progreso de subida
class UpdateUploadProgressEvent extends UploadEvent {
  final double progress;
  final String status;

  const UpdateUploadProgressEvent({
    required this.progress,
    required this.status,
  });

  @override
  List<Object?> get props => [progress, status];
}

/// Evento para resetear el estado de subida
class ResetUploadEvent extends UploadEvent {}
