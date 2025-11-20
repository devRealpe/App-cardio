// lib/domain/entities/lote_audios.dart
import 'package:equatable/equatable.dart';

/// Representa un lote de audios a procesar
class LoteAudios extends Equatable {
  final List<AudioParaProcesar> audios;
  final String? origenPdf;
  final DateTime fechaCreacion;

  const LoteAudios({
    required this.audios,
    this.origenPdf,
    required this.fechaCreacion,
  });

  int get cantidadAudios => audios.length;
  bool get esLote => audios.length > 1;

  @override
  List<Object?> get props => [audios, origenPdf, fechaCreacion];
}

/// Un audio individual dentro de un lote
class AudioParaProcesar extends Equatable {
  final String path;
  final String nombre;
  final int indice; // 1, 2, 3... para el sufijo
  final bool procesado;

  const AudioParaProcesar({
    required this.path,
    required this.nombre,
    required this.indice,
    this.procesado = false,
  });

  /// Obtiene el sufijo secuencial (01, 02, 03...)
  String get sufijo => indice.toString().padLeft(2, '0');

  AudioParaProcesar copyWith({
    String? path,
    String? nombre,
    int? indice,
    bool? procesado,
  }) {
    return AudioParaProcesar(
      path: path ?? this.path,
      nombre: nombre ?? this.nombre,
      indice: indice ?? this.indice,
      procesado: procesado ?? this.procesado,
    );
  }

  @override
  List<Object?> get props => [path, nombre, indice, procesado];
}
