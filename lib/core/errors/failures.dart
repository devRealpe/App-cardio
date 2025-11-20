// lib/core/errors/failures.dart

import 'package:equatable/equatable.dart';

/// Clase base abstracta para los fallos de la aplicación
/// Usamos Equatable para facilitar la comparación de fallos
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================================
// Failures de Configuración
// ============================================================================

/// Fallo al cargar o procesar la configuración local
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error al cargar configuración local']);
}

// ============================================================================
// Failures de Red y Conectividad
// ============================================================================

/// Fallo de conexión a internet
class NetworkFailure extends Failure {
  const NetworkFailure(
      [super.message = 'Error de conexión. Verifica tu internet']);
}

/// Fallo en comunicación con el servidor
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error en el servidor']);
}

// ============================================================================
// Failures de Almacenamiento (AWS S3)
// ============================================================================

/// Fallo al subir o gestionar archivos en almacenamiento
class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Error al subir archivos']);
}

// ============================================================================
// Failures de Validación
// ============================================================================

/// Fallo de validación de datos del formulario
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Datos inválidos']);
}

// ============================================================================
// Failures de Archivos
// ============================================================================

/// Fallo al procesar archivos locales
class FileFailure extends Failure {
  const FileFailure([super.message = 'Error al procesar el archivo']);
}

// ============================================================================
// Failures Generales
// ============================================================================

/// Fallo inesperado que no encaja en otras categorías
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Error inesperado']);
}

/// Fallo de permisos
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permisos insuficientes']);
}
