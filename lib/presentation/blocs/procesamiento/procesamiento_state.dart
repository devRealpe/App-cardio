import 'package:equatable/equatable.dart';
import '../../../domain/entities/lote_audios.dart';

abstract class ProcesamientoState extends Equatable {
  const ProcesamientoState();

  @override
  List<Object?> get props => [];
}

class ProcesamientoInitial extends ProcesamientoState {}

class ProcesamientoEnProgreso extends ProcesamientoState {
  final String paso;
  final double progreso;

  const ProcesamientoEnProgreso({
    required this.paso,
    required this.progreso,
  });

  @override
  List<Object?> get props => [paso, progreso];
}

class ProcesamientoCompletado extends ProcesamientoState {
  final LoteAudios lote;

  const ProcesamientoCompletado({required this.lote});

  @override
  List<Object?> get props => [lote];
}

class ProcesamientoError extends ProcesamientoState {
  final String mensaje;

  const ProcesamientoError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}
