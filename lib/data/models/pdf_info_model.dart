import '../../domain/entities/pdf_info.dart';

class PdfInfoModel extends PdfInfo {
  const PdfInfoModel({
    required super.pdfPath,
    super.linkDescarga,
    super.textoExtraido,
  });

  factory PdfInfoModel.fromEntity(PdfInfo entity) {
    return PdfInfoModel(
      pdfPath: entity.pdfPath,
      linkDescarga: entity.linkDescarga,
      textoExtraido: entity.textoExtraido,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pdf_path': pdfPath,
      'link_descarga': linkDescarga,
      'texto_extraido': textoExtraido,
    };
  }

  factory PdfInfoModel.fromJson(Map<String, dynamic> json) {
    return PdfInfoModel(
      pdfPath: json['pdf_path'] as String,
      linkDescarga: json['link_descarga'] as String?,
      textoExtraido: json['texto_extraido'] as String?,
    );
  }
}
