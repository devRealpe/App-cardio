import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/archivo_procesable.dart';
import '../../../domain/entities/lote_audios.dart';
import '../../../domain/usecases/extraer_link_pdf_usecase.dart';
import '../../../domain/usecases/descargar_archivo_usecase.dart';
import '../../../domain/usecases/descomprimir_zip_usecase.dart';
import 'procesamiento_event.dart';
import 'procesamiento_state.dart';

class ProcesamientoBloc extends Bloc<ProcesamientoEvent, ProcesamientoState> {
  final ExtraerLinkPdfUseCase extraerLinkPdfUseCase;
  final DescargarArchivoUseCase descargarArchivoUseCase;
  final DescomprimirZipUseCase descomprimirZipUseCase;

  ProcesamientoBloc({
    required this.extraerLinkPdfUseCase,
    required this.descargarArchivoUseCase,
    required this.descomprimirZipUseCase,
  }) : super(ProcesamientoInitial()) {
    on<ProcesarArchivoEvent>(_onProcesarArchivo);
    on<ResetProcesamientoEvent>(_onReset);
  }

  Future<void> _onProcesarArchivo(
    ProcesarArchivoEvent event,
    Emitter<ProcesamientoState> emit,
  ) async {
    final archivo = ArchivoProcesable(
      path: event.filePath,
      tipo: ArchivoProcesable.detectarTipo(event.filePath),
      nombre: event.filePath.split('/').last,
      tamanoBytes: await File(event.filePath).length(),
    );

    switch (archivo.tipo) {
      case TipoArchivo.wav:
        await _procesarWav(archivo, emit);
        break;
      case TipoArchivo.pdf:
        await _procesarPdf(archivo, emit);
        break;
      case TipoArchivo.zip:
        await _procesarZip(archivo, emit);
        break;
    }
  }

  Future<void> _procesarWav(
    ArchivoProcesable archivo,
    Emitter<ProcesamientoState> emit,
  ) async {
    emit(ProcesamientoEnProgreso(
      paso: 'Archivo WAV detectado',
      progreso: 1.0,
    ));

    // Crear lote con un solo audio
    final lote = LoteAudios(
      audios: [
        AudioParaProcesar(
          path: archivo.path,
          nombre: archivo.nombre,
          indice: 1,
        ),
      ],
      fechaCreacion: DateTime.now(),
    );

    emit(ProcesamientoCompletado(lote: lote));
  }

  Future<void> _procesarPdf(
    ArchivoProcesable archivo,
    Emitter<ProcesamientoState> emit,
  ) async {
    // 1. Extraer link del PDF
    emit(ProcesamientoEnProgreso(
      paso: 'Extrayendo link del PDF...',
      progreso: 0.2,
    ));

    final pdfInfoResult = await extraerLinkPdfUseCase(File(archivo.path));

    await pdfInfoResult.fold(
      (failure) async {
        emit(ProcesamientoError(mensaje: failure.message));
      },
      (pdfInfo) async {
        if (!pdfInfo.tieneLink) {
          emit(ProcesamientoError(
            mensaje: 'No se encontró un link de descarga en el PDF',
          ));
          return;
        }

        // 2. Descargar archivo desde el link
        emit(ProcesamientoEnProgreso(
          paso: 'Descargando archivo...',
          progreso: 0.4,
        ));

        final archivoDescargado = await descargarArchivoUseCase(
          url: pdfInfo.linkDescarga!,
          onProgress: (progress) {
            emit(ProcesamientoEnProgreso(
              paso: 'Descargando archivo...',
              progreso: 0.4 + (progress * 0.4),
            ));
          },
        );

        await archivoDescargado.fold(
          (failure) async {
            emit(ProcesamientoError(mensaje: failure.message));
          },
          (file) async {
            // 3. Detectar si es WAV o ZIP
            final extension = file.path.toLowerCase().split('.').last;

            if (extension == 'wav') {
              await _procesarWavDescargado(file, pdfInfo.pdfPath, emit);
            } else if (extension == 'zip') {
              await _procesarZipDescargado(file, pdfInfo.pdfPath, emit);
            } else {
              emit(ProcesamientoError(
                mensaje: 'Formato de archivo no soportado: $extension',
              ));
            }
          },
        );
      },
    );
  }

  Future<void> _procesarWavDescargado(
    File wavFile,
    String origenPdf,
    Emitter<ProcesamientoState> emit,
  ) async {
    emit(ProcesamientoEnProgreso(
      paso: 'Archivo WAV descargado',
      progreso: 1.0,
    ));

    final lote = LoteAudios(
      audios: [
        AudioParaProcesar(
          path: wavFile.path,
          nombre: wavFile.path.split('/').last,
          indice: 1,
        ),
      ],
      origenPdf: origenPdf,
      fechaCreacion: DateTime.now(),
    );

    emit(ProcesamientoCompletado(lote: lote));
  }

  Future<void> _procesarZip(
    ArchivoProcesable archivo,
    Emitter<ProcesamientoState> emit,
  ) async {
    await _procesarZipDescargado(File(archivo.path), null, emit);
  }

  Future<void> _procesarZipDescargado(
    File zipFile,
    String? origenPdf,
    Emitter<ProcesamientoState> emit,
  ) async {
    emit(ProcesamientoEnProgreso(
      paso: 'Descomprimiendo ZIP...',
      progreso: 0.9,
    ));

    final archivosResult = await descomprimirZipUseCase(zipFile);

    archivosResult.fold(
      (failure) {
        emit(ProcesamientoError(mensaje: failure.message));
      },
      (archivos) {
        final lote = LoteAudios(
          audios: archivos.asMap().entries.map((entry) {
            return AudioParaProcesar(
              path: entry.value.path,
              nombre: entry.value.path.split('/').last,
              indice: entry.key + 1,
            );
          }).toList(),
          origenPdf: origenPdf,
          fechaCreacion: DateTime.now(),
        );

        emit(ProcesamientoCompletado(lote: lote));
      },
    );
  }

  void _onReset(
    ResetProcesamientoEvent event,
    Emitter<ProcesamientoState> emit,
  ) {
    emit(ProcesamientoInitial());
  }
}
