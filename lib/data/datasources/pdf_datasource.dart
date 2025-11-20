import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../core/errors/exceptions.dart';

abstract class PdfDataSource {
  /// Extrae el primer link encontrado en un PDF
  Future<String?> extraerLink(File pdfFile);

  /// Extrae todo el texto del PDF
  Future<String> extraerTexto(File pdfFile);
}

class PdfDataSourceImpl implements PdfDataSource {
  // Patrón para detectar URLs
  static final _urlPattern = RegExp(
    r'https?://[^\s\)\]]+',
    caseSensitive: false,
  );

  @override
  Future<String?> extraerLink(File pdfFile) async {
    try {
      final texto = await extraerTexto(pdfFile);
      final match = _urlPattern.firstMatch(texto);
      return match?.group(0);
    } catch (e) {
      throw FileException('Error al extraer link del PDF: $e');
    }
  }

  @override
  Future<String> extraerTexto(File pdfFile) async {
    try {
      // Cargar el PDF
      final bytes = await pdfFile.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      String textoCompleto = '';

      // Extraer texto de todas las páginas
      for (int i = 0; i < document.pages.count; i++) {
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        textoCompleto += extractor.extractText(startPageIndex: i);
      }

      document.dispose();

      return textoCompleto;
    } catch (e) {
      throw FileException('Error al extraer texto del PDF: $e');
    }
  }
}
