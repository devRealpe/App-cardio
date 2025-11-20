import 'package:equatable/equatable.dart';

enum TipoArchivo { wav, pdf, zip }

/// Entidad que representa un archivo que puede ser procesado
class ArchivoProcesable extends Equatable {
  final String path;
  final TipoArchivo tipo;
  final String nombre;
  final int tamanoBytes;

  const ArchivoProcesable({
    required this.path,
    required this.tipo,
    required this.nombre,
    required this.tamanoBytes,
  });

  @override
  List<Object?> get props => [path, tipo, nombre, tamanoBytes];

  /// Detecta el tipo de archivo por extensión
  static TipoArchivo detectarTipo(String path) {
    final extension = path.toLowerCase().split('.').last;
    switch (extension) {
      case 'wav':
        return TipoArchivo.wav;
      case 'pdf':
        return TipoArchivo.pdf;
      case 'zip':
        return TipoArchivo.zip;
      default:
        throw ArgumentError('Tipo de archivo no soportado: $extension');
    }
  }
}
