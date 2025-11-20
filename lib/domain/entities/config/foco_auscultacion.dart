// lib/domain/entities/config/foco_auscultacion.dart
import 'package:equatable/equatable.dart';

class FocoAuscultacion extends Equatable {
  final String nombre;
  final String codigo;

  const FocoAuscultacion({
    required this.nombre,
    required this.codigo,
  });

  @override
  List<Object?> get props => [nombre, codigo];
}
