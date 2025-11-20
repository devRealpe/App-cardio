// lib/domain/entities/config/hospital.dart
import 'package:equatable/equatable.dart';

class Hospital extends Equatable {
  final String nombre;
  final String codigo;

  const Hospital({
    required this.nombre,
    required this.codigo,
  });

  @override
  List<Object?> get props => [nombre, codigo];
}




//