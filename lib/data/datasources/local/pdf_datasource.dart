import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../core/errors/exceptions.dart';

abstract class PdfDataSource {
  /// Extrae el primer link encontrado en un PDF
  Future<String?> extraerLink(File pdfFile);

  /// Extrae todo el texto del PDF
  Future<String?> extraerTexto(File pdfFile);
}

class PdfDataSourceImpl implements PdfDataSource {
  @override
  Future<String?> extraerLink(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);

      // Buscar anotaciones (links) en todas las páginas
      for (int i = 0; i < document.pages.count; i++) {
        final page = document.pages[i];

        // Buscar anotaciones de link
        for (int j = 0; j < page.annotations.count; j++) {
          final annotation = page.annotations[j];
          if (annotation is PdfUriAnnotation) {
            final uri = annotation.uri;
            document.dispose();
            return uri;
          }
        }
      }

      // Si no hay anotaciones, buscar en el texto
      final texto = await extraerTexto(pdfFile);
      if (texto != null) {
        final urlPattern = RegExp(
          r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
        );
        final match = urlPattern.firstMatch(texto);
        if (match != null) {
          document.dispose();
          return match.group(0);
        }
      }

      document.dispose();
      return null;
    } catch (e) {
      throw FileException('Error al extraer link del PDF: $e');
    }
  }

  @override
  Future<String?> extraerTexto(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);

      final textExtractor = PdfTextExtractor(document);
      final texto = textExtractor.extractText();

      document.dispose();
      return texto;
    } catch (e) {
      throw FileException('Error al extraer texto del PDF: $e');
    }
  }
}
