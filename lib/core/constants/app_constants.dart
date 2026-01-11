// lib/core/constants/app_constants.dart

/// Constantes globales de la aplicación
class AppConstants {
  AppConstants._(); // Prevenir instanciación

  // Información de la aplicación
  static const String appName = 'ASCS - Etiquetado Cardíaco';
  static const String appVersion = '1.0.0';

  // Configuración de AWS S3
  static const String s3BucketName = 'repositoryec237-dev';
  static const String s3Region = 'us-east-1';
  static const String s3AudioPrefix = 'public/audios/';
  static const String s3JsonPrefix = 'public/audios-json/';

  // Extensiones de archivo permitidas
  static const List<String> allowedAudioExtensions = ['wav'];

  // Límites de tamaño
  static const int maxAudioFileSizeMB = 50;

  // Formatos de fecha
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm:ss';

  // Validaciones
  static const int minAge = 0;
  static const int maxAge = 120;

  // Configuración de formulario
  static const int maxObservacionesLength = 500;
  static const int audioIdPadding = 4; // Formato: 0001, 0002, etc.

  // Mensajes de error
  static const String errorNoInternet =
      'No hay conexión a internet. Por favor, verifica tu conexión.';
  static const String errorGeneral =
      'Ocurrió un error inesperado. Inténtalo nuevamente.';
  static const String errorArchivoNoSeleccionado =
      'Debes seleccionar un archivo de audio válido (.wav)';
  static const String errorCamposIncompletos =
      'Por favor, completa todos los campos obligatorios';

  // Mensajes de éxito
  static const String successFormularioEnviado =
      'Formulario enviado exitosamente';
  static const String successArchivoSubido = 'Archivo subido correctamente';
}
