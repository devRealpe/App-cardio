// lib/data/repositories/archivo_repository_impl.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:path/path.dart' as path;
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/pdf_info.dart';
import '../../domain/repositories/archivo_repository.dart';
import '../datasources/local/pdf_datasource.dart';
import '../datasources/local/zip_datasource.dart';
import '../datasources/remote/download_datasource.dart';

class ArchivoRepositoryImpl implements ArchivoRepository {
  final PdfDataSource pdfDataSource;
  final DownloadDataSource downloadDataSource;
  final ZipDataSource zipDataSource;

  ArchivoRepositoryImpl({
    required this.pdfDataSource,
    required this.downloadDataSource,
    required this.zipDataSource,
  });

  @override
  Future<Either<Failure, PdfInfo>> extraerInfoPdf(File pdfFile) async {
    try {
      final link = await pdfDataSource.extraerLink(pdfFile);
      final texto = await pdfDataSource.extraerTexto(pdfFile);

      final pdfInfo = PdfInfo(
        pdfPath: pdfFile.path,
        linkDescarga: link,
        textoExtraido: texto,
      );

      return Right(pdfInfo);
    } on FileException catch (e) {
      return Left(FileFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error al procesar PDF: $e'));
    }
  }

  @override
  Future<Either<Failure, File>> descargarArchivo({
    required String url,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Detectar nombre del archivo desde la URL
      final uri = Uri.parse(url);
      final nombreArchivo = path.basename(uri.path);

      final archivo = await downloadDataSource.descargarArchivo(
        url: url,
        nombreArchivo: nombreArchivo.isNotEmpty ? nombreArchivo : 'audio.wav',
        onProgress: (received, total) {
          if (total > 0) {
            onProgress?.call(received / total);
          }
        },
      );

      return Right(archivo);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error al descargar archivo: $e'));
    }
  }

  @override
  Future<Either<Failure, List<File>>> descomprimirZip(File zipFile) async {
    try {
      final archivos = await zipDataSource.descomprimirZip(zipFile);

      if (archivos.isEmpty) {
        return const Left(
          FileFailure('No se encontraron archivos WAV en el ZIP'),
        );
      }

      return Right(archivos);
    } on FileException catch (e) {
      return Left(FileFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error al descomprimir ZIP: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> esZipValido(File file) async {
    try {
      final esValido = await zipDataSource.esZipValido(file);
      return Right(esValido);
    } catch (e) {
      return Left(UnexpectedFailure('Error al validar ZIP: $e'));
    }
  }
}
