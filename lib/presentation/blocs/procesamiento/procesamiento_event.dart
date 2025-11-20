import 'package:equatable/equatable.dart';

abstract class ProcesamientoEvent extends Equatable {
  const ProcesamientoEvent();

  @override
  List<Object?> get props => [];
}

class ProcesarArchivoEvent extends ProcesamientoEvent {
  final String filePath;

  const ProcesarArchivoEvent({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

class ResetProcesamientoEvent extends ProcesamientoEvent {}
