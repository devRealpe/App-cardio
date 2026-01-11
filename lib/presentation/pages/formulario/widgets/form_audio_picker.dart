// lib/presentation/pages/formulario/widgets/form_audio_picker.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../theme/medical_colors.dart';

class FormAudioPicker extends StatefulWidget {
  final Function(String) onFileSelected;

  const FormAudioPicker({
    super.key,
    required this.onFileSelected,
  });

  @override
  State<FormAudioPicker> createState() => FormAudioPickerState();
}

// CORRECCIÓN: Quitar el guion bajo para hacerlo público
class FormAudioPickerState extends State<FormAudioPicker> {
  String? _selectedFileName;
  String? _selectedFilePath;
  bool _isHovering = false;

  // CORRECCIÓN: Hacer el método reset público
  void reset() {
    setState(() {
      _selectedFileName = null;
      _selectedFilePath = null;
      _isHovering = false;
    });
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedFilePath = result.files.single.path;
      });
      widget.onFileSelected(_selectedFilePath!);
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(),
            const SizedBox(height: 24),
            _buildPickerArea(),
            if (_selectedFileName == null) _buildHelpText(),
          ],
        ),
      ),
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
              Icons.audiotrack,
              color: MedicalColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Archivo de Audio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MedicalColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerArea() {
    return GestureDetector(
      onTap: _pickAudioFile,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: _selectedFileName != null
                ? LinearGradient(
                    colors: [
                      MedicalColors.successGreen.withAlpha((0.1 * 255).toInt()),
                      MedicalColors.successGreen
                          .withAlpha((0.05 * 255).toInt()),
                    ],
                  )
                : null,
            border: Border.all(
              color: _selectedFileName != null
                  ? MedicalColors.successGreen
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
                    : Icons.audiotrack,
                size: 48,
                color: _selectedFileName != null
                    ? MedicalColors.successGreen
                    : MedicalColors.primaryBlue,
              ),
              const SizedBox(height: 20),
              Text(
                _selectedFileName != null
                    ? 'Archivo cargado exitosamente'
                    : 'Seleccionar archivo de audio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _selectedFileName != null
                      ? MedicalColors.successGreen
                      : MedicalColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedFileName != null
                    ? 'Toca para cambiar el archivo'
                    : 'Toca aquí para elegir un archivo .wav',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              if (_selectedFileName != null) ...[
                const SizedBox(height: 20),
                Container(
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
                          color: MedicalColors.successGreen
                              .withAlpha((0.1 * 255).toInt()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.audio_file,
                          color: MedicalColors.successGreen,
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
                            Text(
                              _getFileSize(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpText() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Solo se permiten archivos en formato WAV',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
