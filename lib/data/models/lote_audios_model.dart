import '../../domain/entities/lote_audios.dart';

class LoteAudiosModel extends LoteAudios {
  const LoteAudiosModel({
    required super.audios,
    super.origenPdf,
    required super.fechaCreacion,
  });

  factory LoteAudiosModel.fromFiles({
    required List<String> paths,
    String? origenPdf,
  }) {
    final audios = <AudioParaProcesar>[];

    for (int i = 0; i < paths.length; i++) {
      final filePath = paths[i];
      audios.add(
        AudioParaProcesar(
          path: filePath,
          nombre: filePath.split('/').last,
          indice: i + 1,
        ),
      );
    }

    return LoteAudiosModel(
      audios: audios,
      origenPdf: origenPdf,
      fechaCreacion: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audios': audios
          .map((a) => {
                'path': a.path,
                'nombre': a.nombre,
                'indice': a.indice,
                'procesado': a.procesado,
              })
          .toList(),
      'origen_pdf': origenPdf,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }
}
