import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/pdf_info.dart';

abstract class ArchivoRepository {
  /// Extrae información de un PDF (link y texto)
  Future<Either<Failure, PdfInfo>> extraerInfoPdf(File pdfFile);

  /// Descarga un archivo desde una URL
  Future<Either<Failure, File>> descargarArchivo({
    required String url,
    void Function(double progress)? onProgress,
  });

  /// Descomprime un archivo ZIP y retorna los WAV
  Future<Either<Failure, List<File>>> descomprimirZip(File zipFile);

  /// Verifica si un archivo es ZIP válido
  Future<Either<Failure, bool>> esZipValido(File file);
}
