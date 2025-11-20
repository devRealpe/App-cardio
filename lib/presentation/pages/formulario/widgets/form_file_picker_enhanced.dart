// ============================================================================
// lib/presentation/pages/formulario/widgets/form_file_picker_enhanced.dart
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/procesamiento/procesamiento_bloc.dart';
import '../../../blocs/procesamiento/procesamiento_event.dart';
import '../../../blocs/procesamiento/procesamiento_state.dart';
import '../../../theme/medical_colors.dart';

class FormFilePickerEnhanced extends StatefulWidget {
  final Function(String) onFileProcessed;

  const FormFilePickerEnhanced({
    super.key,
    required this.onFileProcessed,
  });

  @override
  State<FormFilePickerEnhanced> createState() => FormFilePickerEnhancedState();
}

class FormFilePickerEnhancedState extends State<FormFilePickerEnhanced> {
  String? _selectedFileName;
  String? _selectedFilePath;
  String? _fileType;
  bool _isHovering = false;

  void reset() {
    setState(() {
      _selectedFileName = null;
      _selectedFilePath = null;
      _fileType = null;
      _isHovering = false;
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav', 'pdf', 'zip'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      final extension = file.extension?.toLowerCase();

      setState(() {
        _selectedFileName = file.name;
        _selectedFilePath = file.path;
        _fileType = extension;
      });

      // Procesar el archivo
      if (_selectedFilePath != null && mounted) {
        context.read<ProcesamientoBloc>().add(
              ProcesarArchivoEvent(filePath: _selectedFilePath!),
            );
      }
    }
  }

  String _getFileSize() {
    if (_selectedFilePath == null) return '';
    final file = File(_selectedFilePath!);
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon() {
    switch (_fileType) {
      case 'wav':
        return Icons.audio_file;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'zip':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor() {
    switch (_fileType) {
      case 'wav':
        return MedicalColors.primaryBlue;
      case 'pdf':
        return MedicalColors.errorRed;
      case 'zip':
        return MedicalColors.warningOrange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProcesamientoBloc, ProcesamientoState>(
      listener: (context, state) {
        if (state is ProcesamientoCompletado) {
          widget.onFileProcessed(_selectedFilePath!);
        } else if (state is ProcesamientoError) {
          _showError(context, state.mensaje);
        }
      },
      builder: (context, state) {
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader(),
                const SizedBox(height: 24),
                _buildPickerArea(state),
                if (_selectedFileName == null &&
                    state is! ProcesamientoEnProgreso)
                  _buildHelpText(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MedicalColors.primaryBlue.withAlpha((0.08 * 255).toInt()),
            MedicalColors.primaryBlue.withAlpha((0.03 * 255).toInt()),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: MedicalColors.primaryBlue, width: 4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MedicalColors.primaryBlue.withAlpha((0.15 * 255).toInt()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.upload_file,
              color: MedicalColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Seleccionar Archivo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MedicalColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerArea(ProcesamientoState state) {
    if (state is ProcesamientoEnProgreso) {
      return _buildProgressIndicator(state);
    }

    return GestureDetector(
      onTap: _pickFile,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: _selectedFileName != null
                ? LinearGradient(
                    colors: [
                      _getFileColor().withAlpha((0.1 * 255).toInt()),
                      _getFileColor().withAlpha((0.05 * 255).toInt()),
                    ],
                  )
                : null,
            border: Border.all(
              color: _selectedFileName != null
                  ? _getFileColor()
                  : (_isHovering
                      ? MedicalColors.primaryBlue
                      : Colors.grey.shade300),
              width: _isHovering || _selectedFileName != null ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            children: [
              Icon(
                _selectedFileName != null
                    ? Icons.check_circle
                    : Icons.upload_file,
                size: 48,
                color: _selectedFileName != null
                    ? _getFileColor()
                    : MedicalColors.primaryBlue,
              ),
              const SizedBox(height: 20),
              Text(
                _selectedFileName != null
                    ? 'Archivo cargado exitosamente'
                    : 'Seleccionar archivo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _selectedFileName != null
                      ? _getFileColor()
                      : MedicalColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedFileName != null
                    ? 'Toca para cambiar el archivo'
                    : 'Toca aquí para elegir un archivo (.wav, .pdf, .zip)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              if (_selectedFileName != null) ...[
                const SizedBox(height: 20),
                _buildFileInfo(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getFileColor().withAlpha((0.1 * 255).toInt()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(),
              color: _getFileColor(),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFileName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _getFileSize(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getFileColor().withAlpha((0.15 * 255).toInt()),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _fileType?.toUpperCase() ?? '',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getFileColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ProcesamientoEnProgreso state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MedicalColors.primaryBlue.withAlpha((0.05 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MedicalColors.primaryBlue,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: state.progreso,
              strokeWidth: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(
                MedicalColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            state.paso,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: MedicalColors.primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${(state.progreso * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: MedicalColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpText() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Formatos permitidos:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildFormatInfo(
              'WAV', 'Audio directo para etiquetar', Icons.audiotrack),
          _buildFormatInfo(
              'PDF', 'Extrae link y descarga audio/zip', Icons.picture_as_pdf),
          _buildFormatInfo(
              'ZIP', 'Múltiples audios en un archivo', Icons.folder_zip),
        ],
      ),
    );
  }

  Widget _buildFormatInfo(String format, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Text(
            '$format:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: MedicalColors.errorRed,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
