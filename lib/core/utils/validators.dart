// lib/core/utils/validators.dart

import 'dart:io';
import '../constants/app_constants.dart';

/// Clase de utilidades para validaciones
class Validators {
  Validators._(); // Prevenir instanciación

  /// Valida que un campo no esté vacío
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  /// Valida que una fecha no sea nula
  static String? validateDate(DateTime? date) {
    if (date == null) {
      return 'Debes seleccionar una fecha';
    }
    if (date.isAfter(DateTime.now())) {
      return 'La fecha no puede ser futura';
    }
    return null;
  }

  /// Valida que la edad esté en un rango válido
  static String? validateAge(DateTime fechaNacimiento) {
    final edad = DateTime.now().difference(fechaNacimiento).inDays ~/ 365;

    if (edad < AppConstants.minAge || edad > AppConstants.maxAge) {
      return 'La edad debe estar entre ${AppConstants.minAge} y ${AppConstants.maxAge} años';
    }
    return null;
  }

  /// Valida que un archivo exista y sea válido
  static String? validateAudioFile(String? filePath) {
    if (filePath == null || filePath.isEmpty) {
      return AppConstants.errorArchivoNoSeleccionado;
    }

    final file = File(filePath);
    if (!file.existsSync()) {
      return 'El archivo no existe';
    }

    // Validar extensión
    final extension = filePath.split('.').last.toLowerCase();
    if (!AppConstants.allowedAudioExtensions.contains(extension)) {
      return 'Solo se permiten archivos con extensión: ${AppConstants.allowedAudioExtensions.join(", ")}';
    }

    // Validar tamaño
    final fileSizeInBytes = file.lengthSync();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    if (fileSizeInMB > AppConstants.maxAudioFileSizeMB) {
      return 'El archivo no debe superar ${AppConstants.maxAudioFileSizeMB} MB';
    }

    return null;
  }

  /// Valida la longitud máxima de un texto
  static String? validateMaxLength(
      String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName no debe superar $maxLength caracteres';
    }
    return null;
  }

  /// Valida que un valor esté en una lista de opciones
  static String? validateOption(
      String? value, List<String> options, String fieldName) {
    if (value == null || !options.contains(value)) {
      return 'Selecciona una opción válida para $fieldName';
    }
    return null;
  }

  /// Valida el formulario completo
  static Map<String, String> validateFormulario({
    required String? hospital,
    required String? consultorio,
    required String? estado,
    required String? focoAuscultacion,
    required DateTime? fechaNacimiento,
    required String? audioFilePath,
    List<String>? hospitalesValidos,
    List<String>? consultoriosValidos,
    List<String>? estadosValidos,
    List<String>? focosValidos,
  }) {
    final errors = <String, String>{};

    // Validar hospital
    final hospitalError = validateRequired(hospital, 'Hospital');
    if (hospitalError != null) errors['hospital'] = hospitalError;

    // Validar consultorio
    final consultorioError = validateRequired(consultorio, 'Consultorio');
    if (consultorioError != null) errors['consultorio'] = consultorioError;

    // Validar estado
    final estadoError = validateRequired(estado, 'Estado');
    if (estadoError != null) errors['estado'] = estadoError;

    // Validar foco de auscultación
    final focoError =
        validateRequired(focoAuscultacion, 'Foco de auscultación');
    if (focoError != null) errors['foco'] = focoError;

    // Validar fecha de nacimiento
    final fechaError = validateDate(fechaNacimiento);
    if (fechaError != null) {
      errors['fecha'] = fechaError;
    } else if (fechaNacimiento != null) {
      final edadError = validateAge(fechaNacimiento);
      if (edadError != null) errors['edad'] = edadError;
    }

    // Validar archivo de audio
    final audioError = validateAudioFile(audioFilePath);
    if (audioError != null) errors['audio'] = audioError;

    return errors;
  }
}
