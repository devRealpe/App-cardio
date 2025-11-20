import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';

/// Wrapper para manejar archivos de audio en móvil y web
class AudioFileWrapper {
  final String? filePath;
  final PlatformFile? platformFile;
  final String fileName;
  final int size;

  AudioFileWrapper({
    this.filePath,
    this.platformFile,
    required this.fileName,
    required this.size,
  });

  /// Verifica si el archivo existe/es válido
  bool get isValid {
    if (kIsWeb) {
      return platformFile != null && platformFile!.bytes != null;
    } else {
      return filePath != null && File(filePath!).existsSync();
    }
  }

  /// Obtiene los bytes del archivo
  Future<Uint8List> getBytes() async {
    if (kIsWeb) {
      if (platformFile?.bytes == null) {
        throw Exception('No hay bytes disponibles en web');
      }
      return platformFile!.bytes!;
    } else {
      if (filePath == null) {
        throw Exception('No hay ruta de archivo en móvil');
      }
      return await File(filePath!).readAsBytes();
    }
  }

  /// Obtiene el archivo (solo móvil)
  File? getFile() {
    if (kIsWeb) return null;
    if (filePath == null) return null;
    return File(filePath!);
  }

  /// Valida el tamaño del archivo
  bool isValidSize(int maxSizeMB) {
    final maxBytes = maxSizeMB * 1024 * 1024;
    return size <= maxBytes;
  }

  /// Valida la extensión
  bool hasValidExtension(List<String> allowedExtensions) {
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }
}
