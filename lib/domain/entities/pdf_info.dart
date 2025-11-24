// lib/domain/entities/pdf_info.dart
import 'package:equatable/equatable.dart';

/// Información extraída de un PDF
class PdfInfo extends Equatable {
  final String pdfPath;
  final String? linkDescarga;
  final String? textoExtraido;

  const PdfInfo({
    required this.pdfPath,
    this.linkDescarga,
    this.textoExtraido,
  });

  bool get tieneLink => linkDescarga != null && linkDescarga!.isNotEmpty;

  @override
  List<Object?> get props => [pdfPath, linkDescarga, textoExtraido];
}
