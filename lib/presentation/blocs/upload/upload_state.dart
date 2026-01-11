// lib/presentation/blocs/upload/upload_state.dart

import 'package:equatable/equatable.dart';

abstract class UploadState extends Equatable {
  const UploadState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial de subida
class UploadInitial extends UploadState {}

/// Estado de subida en progreso
class UploadInProgress extends UploadState {
  final double progress;
  final String status;

  const UploadInProgress({
    required this.progress,
    required this.status,
  });

  @override
  List<Object?> get props => [progress, status];
}

/// Estado de subida completada
class UploadCompleted extends UploadState {}

/// Estado de error en subida
class UploadError extends UploadState {
  final String message;

  const UploadError({required this.message});

  @override
  List<Object?> get props => [message];
}
