// lib/data/models/config/hospital_model.dart
import '../../../domain/entities/config/hospital.dart';

class HospitalModel extends Hospital {
  const HospitalModel({
    required super.nombre,
    required super.codigo,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'codigo': codigo,
    };
  }
}
