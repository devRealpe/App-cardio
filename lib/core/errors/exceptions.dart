// lib/core/errors/exceptions.dart

// Excepciones personalizadas para el manejo de errores

/// Excepción de servidor/remoto
class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Error en el servidor']);

  @override
  String toString() => 'ServerException: $message';
}

/// Excepción de caché/almacenamiento local
class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Error en el almacenamiento local']);

  @override
  String toString() => 'CacheException: $message';
}

/// Excepción de red/conectividad
class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Error de conexión a internet']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Excepción de validación
class ValidationException implements Exception {
  final String message;

  const ValidationException([this.message = 'Error de validación']);

  @override
  String toString() => 'ValidationException: $message';
}

/// Excepción de archivo
class FileException implements Exception {
  final String message;

  const FileException([this.message = 'Error con el archivo']);

  @override
  String toString() => 'FileException: $message';
}

/// Excepción de almacenamiento (AWS S3)
class StorageException implements Exception {
  final String message;

  const StorageException([this.message = 'Error en el almacenamiento']);

  @override
  String toString() => 'StorageException: $message';
}
