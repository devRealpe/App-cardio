// lib/data/models/config/consultorio_model.dart
import '../../../domain/entities/config/consultorio.dart';

class ConsultorioModel extends Consultorio {
  const ConsultorioModel({
    required super.nombre,
    required super.codigo,
    required super.codigoHospital,
  });

  factory ConsultorioModel.fromJson(Map<String, dynamic> json) {
    return ConsultorioModel(
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      codigoHospital: json['codigo_hospital'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'codigo': codigo,
      'codigo_hospital': codigoHospital,
    };
  }
}
