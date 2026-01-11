// lib/presentation/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'medical_colors.dart';

/// Configuración de temas de la aplicación
class AppTheme {
  AppTheme._(); // Prevenir instanciación

  /// Tema claro de la aplicación
  static ThemeData get lightTheme {
    return ThemeData(
      // Color primario: Azul médico profesional
      primaryColor: MedicalColors.primaryBlue,
      primarySwatch: Colors.blue,

      colorScheme: ColorScheme.fromSeed(
        seedColor: MedicalColors.primaryBlue,
        secondary: MedicalColors.secondaryTeal,
        brightness: Brightness.light,
        error: MedicalColors.errorRed,
        surface: Colors.white,
      ),

      scaffoldBackgroundColor: MedicalColors.backgroundLight,
      cardColor: MedicalColors.cardWhite,

      // Tipografía médica profesional
      textTheme: _buildTextTheme(),

      // Estilos de botones
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),

      // Campos de texto y formularios
      inputDecorationTheme: _buildInputDecorationTheme(),

      // Tarjetas
      cardTheme: _buildCardTheme(),

      // AppBar
      appBarTheme: _buildAppBarTheme(),

      // Diálogos
      dialogTheme: _buildDialogTheme(),

      // Divisores
      dividerTheme: _buildDividerTheme(),

      // Iconos
      iconTheme: const IconThemeData(
        color: MedicalColors.primaryBlue,
        size: 24,
      ),

      // Indicadores de progreso
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: MedicalColors.primaryBlue,
        circularTrackColor: Color(0xFFE3F2FD),
      ),

      // Snackbars
      snackBarTheme: _buildSnackBarTheme(),

      useMaterial3: true,
    );
  }

  /// Tema oscuro de la aplicación
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: MedicalColors.lightBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MedicalColors.lightBlue,
        brightness: Brightness.dark,
        secondary: const Color(0xFF26A69A),
        error: const Color(0xFFEF5350),
        surface: const Color(0xFF1E1E1E),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
        bodyMedium: TextStyle(color: Color(0xFFBDBDBD)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      useMaterial3: true,
    );
  }

  // Métodos privados para construir componentes del tema

  static TextTheme _buildTextTheme() {
    return const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: MedicalColors.primaryBlue,
        letterSpacing: 0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: MedicalColors.textPrimary,
        letterSpacing: 0.5,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: MedicalColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF455A64),
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: MedicalColors.textSecondary,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: MedicalColors.textHint,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MedicalColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: MedicalColors.primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: MedicalColors.primaryBlue,
          width: 2.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      labelStyle: const TextStyle(
        color: MedicalColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 14,
      ),
    );
  }

  static CardThemeData _buildCardTheme() {
    return CardThemeData(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      shadowColor: MedicalColors.primaryBlue.withValues(alpha: 0.15),
      margin: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  static AppBarTheme _buildAppBarTheme() {
    return const AppBarTheme(
      backgroundColor: MedicalColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
        size: 24,
      ),
    );
  }

  static DialogThemeData _buildDialogTheme() {
    return DialogThemeData(
      backgroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: MedicalColors.textPrimary,
      ),
    );
  }

  static DividerThemeData _buildDividerTheme() {
    return DividerThemeData(
      color: Colors.grey.shade300,
      thickness: 1,
      space: 20,
    );
  }

  static SnackBarThemeData _buildSnackBarTheme() {
    return SnackBarThemeData(
      backgroundColor: MedicalColors.textPrimary,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    );
  }
}
