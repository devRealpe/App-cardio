// lib/data/datasources/local/config_local_datasource.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/config/medical_config_model.dart';

/// Contrato para el data source local de configuración
abstract class ConfigLocalDataSource {
  /// Obtiene la configuración médica desde un archivo JSON local
  Future<MedicalConfigModel> obtenerConfiguracion();
}

/// Implementación del data source local de configuración
class ConfigLocalDataSourceImpl implements ConfigLocalDataSource {
  // Ruta del archivo JSON con la configuración
  static const String _configFilePath = 'assets/config/medical_config.json';

  @override
  Future<MedicalConfigModel> obtenerConfiguracion() async {
    try {
      // Cargar el archivo JSON desde assets
      final jsonString = await rootBundle.loadString(_configFilePath);

      // Parsear el JSON
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

      // Convertir a modelo
      return MedicalConfigModel.fromJson(jsonMap);
    } on FormatException catch (e) {
      // Error al parsear JSON (formato inválido)
      throw CacheException(
          'Error al parsear JSON de configuración: ${e.message}');
    } catch (e) {
      // Cualquier otro error (archivo no encontrado, permisos, etc.)
      throw CacheException('Error inesperado al obtener configuración: $e');
    }
  }
}
