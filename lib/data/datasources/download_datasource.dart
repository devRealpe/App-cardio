import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../core/errors/exceptions.dart';

abstract class DownloadDataSource {
  /// Descarga un archivo desde una URL
  Future<File> descargarArchivo({
    required String url,
    required String nombreArchivo,
    void Function(int received, int total)? onProgress,
  });
}

class DownloadDataSourceImpl implements DownloadDataSource {
  final http.Client httpClient;

  DownloadDataSourceImpl({required this.httpClient});

  @override
  Future<File> descargarArchivo({
    required String url,
    required String nombreArchivo,
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      // Hacer request
      final request = http.Request('GET', Uri.parse(url));
      final response = await httpClient.send(request);

      if (response.statusCode != 200) {
        throw NetworkException(
          'Error al descargar: código ${response.statusCode}',
        );
      }

      // Obtener directorio temporal
      final tempDir = await getTemporaryDirectory();
      final filePath = path.join(tempDir.path, nombreArchivo);
      final file = File(filePath);

      // Descargar con progreso
      final contentLength = response.contentLength ?? 0;
      int received = 0;

      final sink = file.openWrite();
      await response.stream.map((chunk) {
        received += chunk.length;
        onProgress?.call(received, contentLength);
        return chunk;
      }).pipe(sink);

      await sink.close();

      return file;
    } on SocketException {
      throw NetworkException('Sin conexión a Internet');
    } catch (e) {
      throw NetworkException('Error al descargar archivo: $e');
    }
  }
}
