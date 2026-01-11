// lib/domain/entities/config/consultorio.dart
import 'package:equatable/equatable.dart';

class Consultorio extends Equatable {
  final String nombre;
  final String codigo;
  final String codigoHospital;

  const Consultorio({
    required this.nombre,
    required this.codigo,
    required this.codigoHospital,
  });

  @override
  List<Object?> get props => [nombre, codigo, codigoHospital];
}
