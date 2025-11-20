// lib/presentation/theme/medical_colors.dart
import 'package:flutter/material.dart';

/// Paleta de colores médicos de la aplicación
class MedicalColors {
  MedicalColors._(); // Prevenir instanciación

  // Colores primarios
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color secondaryTeal = Color(0xFF00897B);
  static const Color accentCyan = Color(0xFF00ACC1);
  static const Color lightBlue = Color(0xFF42A5F5);

  // Colores de estado
  static const Color successGreen = Color(0xFF43A047);
  static const Color warningOrange = Color(0xFFFF6F00);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color infoBlue = Color(0xFF1976D2);

  // Colores de fondo
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFFFAFAFA);
  static const Color dividerGrey = Color(0xFFE0E0E0);

  // Colores de texto
  static const Color textPrimary = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF546E7A);
  static const Color textHint = Color(0xFF90A4AE);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Gradientes personalizados
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F7FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
