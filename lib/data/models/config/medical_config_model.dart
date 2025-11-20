// lib/data/models/config/medical_config_model.dart
import '../../../domain/entities/config/medical_config.dart';
import 'hospital_model.dart';
import 'consultorio_model.dart';
import 'foco_auscultacion_model.dart';

class MedicalConfigModel extends MedicalConfig {
  const MedicalConfigModel({
    required super.hospitales,
    required super.consultorios,
    required super.focos,
  });

  factory MedicalConfigModel.fromJson(Map<String, dynamic> json) {
    return MedicalConfigModel(
      hospitales: (json['hospitales'] as List)
          .map((h) => HospitalModel.fromJson(h as Map<String, dynamic>))
          .toList(),
      consultorios: (json['consultorios'] as List)
          .map((c) => ConsultorioModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      focos: (json['focos'] as List)
          .map((f) => FocoAuscultacionModel.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hospitales':
          hospitales.map((h) => (h as HospitalModel).toJson()).toList(),
      'consultorios':
          consultorios.map((c) => (c as ConsultorioModel).toJson()).toList(),
      'focos': focos.map((f) => (f as FocoAuscultacionModel).toJson()).toList(),
    };
  }
}
