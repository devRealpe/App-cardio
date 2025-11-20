import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../../core/errors/exceptions.dart';

abstract class ZipDataSource {
  /// Descomprime un archivo ZIP y retorna los archivos WAV
  Future<List<File>> descomprimirZip(File zipFile);

  /// Verifica si un archivo es ZIP válido
  Future<bool> esZipValido(File file);
}

class ZipDataSourceImpl implements ZipDataSource {
  @override
  Future<List<File>> descomprimirZip(File zipFile) async {
    try {
      // Leer bytes del ZIP
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Directorio temporal para extraer
      final tempDir = await getTemporaryDirectory();
      final extractPath = path.join(
        tempDir.path,
        'extracted_${DateTime.now().millisecondsSinceEpoch}',
      );
      final extractDir = Directory(extractPath);
      await extractDir.create(recursive: true);

      // Extraer archivos WAV
      final wavFiles = <File>[];

      for (final file in archive) {
        if (file.isFile && file.name.toLowerCase().endsWith('.wav')) {
          final filePath = path.join(extractPath, path.basename(file.name));
          final outputFile = File(filePath);
          await outputFile.writeAsBytes(file.content as List<int>);
          wavFiles.add(outputFile);
        }
      }

      if (wavFiles.isEmpty) {
        throw FileException('No se encontraron archivos WAV en el ZIP');
      }

      return wavFiles;
    } catch (e) {
      throw FileException('Error al descomprimir ZIP: $e');
    }
  }

  @override
  Future<bool> esZipValido(File file) async {
    try {
      final bytes = await file.readAsBytes();
      ZipDecoder().decodeBytes(bytes);
      return true;
    } catch (e) {
      return false;
    }
  }
}
