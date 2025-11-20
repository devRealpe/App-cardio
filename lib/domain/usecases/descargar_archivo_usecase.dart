import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/archivo_repository.dart';

class DescargarArchivoUseCase {
  final ArchivoRepository repository;

  DescargarArchivoUseCase({required this.repository});

  Future<Either<Failure, File>> call({
    required String url,
    void Function(double progress)? onProgress,
  }) async {
    return await repository.descargarArchivo(
      url: url,
      onProgress: onProgress,
    );
  }
}
