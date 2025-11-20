import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/pdf_info.dart';
import '../repositories/archivo_repository.dart';

class ExtraerLinkPdfUseCase {
  final ArchivoRepository repository;

  ExtraerLinkPdfUseCase({required this.repository});

  Future<Either<Failure, PdfInfo>> call(File pdfFile) async {
    return await repository.extraerInfoPdf(pdfFile);
  }
}
