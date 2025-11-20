import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/archivo_repository.dart';

class DescomprimirZipUseCase {
  final ArchivoRepository repository;

  DescomprimirZipUseCase({required this.repository});

  Future<Either<Failure, List<File>>> call(File zipFile) async {
    return await repository.descomprimirZip(zipFile);
  }
}
