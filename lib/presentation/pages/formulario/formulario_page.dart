// ============================================================================
// lib/presentation/pages/formulario/formulario_page_updated.dart
// EJEMPLO DE CÓMO INTEGRAR LA NUEVA FUNCIONALIDAD
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection_container.dart' as di;
import '../../blocs/config/config_bloc.dart';
import '../../blocs/formulario/formulario_bloc.dart';
import '../../blocs/procesamiento/procesamiento_bloc.dart';
import '../../blocs/procesamiento/procesamiento_state.dart';
import '../../theme/medical_colors.dart';
import 'widgets/form_header.dart';
import 'widgets/form_fields.dart';
import 'widgets/form_file_picker_enhanced.dart'; // NUEVO
import 'widgets/upload_overlay.dart';

class FormularioPageUpdated extends StatelessWidget {
  const FormularioPageUpdated({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<FormularioBloc>(),
        ),
        // NUEVO: BLoC de procesamiento de archivos
        BlocProvider(
          create: (context) => di.sl<ProcesamientoBloc>(),
        ),
      ],
      child: const _FormularioPageView(),
    );
  }
}

class _FormularioPageView extends StatefulWidget {
  const _FormularioPageView();

  @override
  State<_FormularioPageView> createState() => _FormularioPageViewState();
}

class _FormularioPageViewState extends State<_FormularioPageView> {
  final _formKey = GlobalKey<FormState>();
  final _filePickerKey = GlobalKey<FormFilePickerEnhancedState>();
  final _formFieldsKey = GlobalKey<FormFieldsState>();

  // NUEVO: Lista de audios pendientes de etiquetar
  List<String> _audiosPendientes = [];
  int _audioActual = 0;

  // Controllers de estado del formulario (igual que antes)
  String? _hospital;
  String? _consultorio;
  String? _estado;
  String? _focoAuscultacion;
  DateTime? _selectedDate;
  String? _observaciones;
  String? _audioFilePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedicalColors.backgroundLight,
      appBar: _buildAppBar(context),
      body: BlocListener<ProcesamientoBloc, ProcesamientoState>(
        listener: _handleProcesamientoState,
        child: _buildFormContent(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return FormHeader(
      onInfoPressed: () => _showInfoDialog(context),
    );
  }

  Widget _buildFormContent() {
    return BlocBuilder<ConfigBloc, ConfigState>(
      builder: (context, configState) {
        if (configState is ConfigLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (configState is ConfigError) {
          return _buildErrorView(configState.message);
        }

        if (configState is! ConfigLoaded) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // NUEVO: Indicador de progreso de lote si hay múltiples audios
                if (_audiosPendientes.length > 1) _buildLoteProgress(),

                FormFields(
                  key: _formFieldsKey,
                  config: configState.config,
                  hospital: _hospital,
                  consultorio: _consultorio,
                  estado: _estado,
                  focoAuscultacion: _focoAuscultacion,
                  selectedDate: _selectedDate,
                  observaciones: _observaciones,
                  mostrarSelectorHospital: true,
                  onHospitalChanged: _onHospitalChanged,
                  onConsultorioChanged: (value) {
                    setState(() => _consultorio = value);
                  },
                  onEstadoChanged: (value) {
                    setState(() => _estado = value);
                  },
                  onFocoChanged: (value) {
                    setState(() => _focoAuscultacion = value);
                  },
                  onDateChanged: (value) {
                    setState(() => _selectedDate = value);
                  },
                  onObservacionesChanged: (value) {
                    _observaciones = value;
                  },
                ),
                const SizedBox(height: 20),

                // NUEVO: Selector de archivos mejorado
                FormFilePickerEnhanced(
                  key: _filePickerKey,
                  onFileProcessed: _handleFileProcessed,
                ),

                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // NUEVO: Widget de progreso de lote
  Widget _buildLoteProgress() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MedicalColors.primaryBlue.withAlpha((0.1 * 255).toInt()),
            MedicalColors.primaryBlue.withAlpha((0.05 * 255).toInt()),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MedicalColors.primaryBlue,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.queue_music,
                color: MedicalColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Procesamiento por lotes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MedicalColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Audio $_audioActual de ${_audiosPendientes.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _audioActual / _audiosPendientes.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation(
              MedicalColors.primaryBlue,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: MedicalColors.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.2 * 255).toInt()),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              _audiosPendientes.length > 1
                  ? 'ETIQUETAR AUDIO $_audioActual/${_audiosPendientes.length}'
                  : 'ENVIAR DATOS',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NUEVO: Maneja el resultado del procesamiento de archivos
  void _handleProcesamientoState(
    BuildContext context,
    ProcesamientoState state,
  ) {
    if (state is ProcesamientoCompletado) {
      final lote = state.lote;

      if (lote.esLote) {
        // Múltiples audios: preparar para etiquetar uno por uno
        setState(() {
          _audiosPendientes = lote.audios.map((a) => a.path).toList();
          _audioActual = 1;
          _audioFilePath = _audiosPendientes.first;
        });

        _showSuccess(
          '${lote.cantidadAudios} audios detectados. '
          'Etiquétalos uno por uno.',
        );
      } else {
        // Un solo audio: etiquetado normal
        setState(() {
          _audiosPendientes = [lote.audios.first.path];
          _audioActual = 1;
          _audioFilePath = lote.audios.first.path;
        });
      }
    }
  }

  // NUEVO: Callback cuando se procesa un archivo
  void _handleFileProcessed(String filePath) {
    // Este método se llama cuando el ProcesamientoBloc termina
    // La lógica real está en _handleProcesamientoState
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showError('Por favor, completa todos los campos obligatorios');
      return;
    }

    if (_audioFilePath == null) {
      _showError('Debes seleccionar un archivo');
      return;
    }

    // Aquí iría la lógica de envío (igual que antes)
    // pero con soporte para múltiples audios

    // Después de enviar exitosamente, pasar al siguiente audio si hay
    if (_audioActual < _audiosPendientes.length) {
      setState(() {
        _audioActual++;
        _audioFilePath = _audiosPendientes[_audioActual - 1];
        // Limpiar solo observaciones, mantener el resto
        _observaciones = null;
        _formFieldsKey.currentState?.reset();
      });
    } else {
      // Terminamos todos los audios
      _resetForm();
      _showSuccess('Todos los audios fueron etiquetados exitosamente');
    }
  }

  void _onHospitalChanged(String? value) {
    setState(() {
      _hospital = value;
      _consultorio = null;
    });

    if (value != null && mounted) {
      final config = context.read<ConfigBloc>().state;
      if (config is ConfigLoaded) {
        final hospital = config.config.getHospitalPorNombre(value);
        if (hospital != null) {
          context.read<ConfigBloc>().add(
                ObtenerConsultoriosPorHospitalEvent(hospital.codigo),
              );
        }
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _filePickerKey.currentState?.reset();
    _formFieldsKey.currentState?.reset();

    setState(() {
      _hospital = null;
      _consultorio = null;
      _estado = null;
      _focoAuscultacion = null;
      _selectedDate = null;
      _observaciones = null;
      _audioFilePath = null;
      _audiosPendientes = [];
      _audioActual = 0;
    });
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: MedicalColors.errorRed),
          const SizedBox(height: 16),
          Text(
            'Error al cargar configuración',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<ConfigBloc>().add(CargarConfiguracionEvent());
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
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
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: MedicalColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: MedicalColors.primaryBlue),
            const SizedBox(width: 12),
            const Text('Información'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Formatos de archivo soportados:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text('📄 PDF: Extrae link y descarga audio/zip automáticamente'),
              SizedBox(height: 8),
              Text('🎵 WAV: Audio individual para etiquetar'),
              SizedBox(height: 8),
              Text('📦 ZIP: Múltiples audios se etiquetan secuencialmente'),
              SizedBox(height: 16),
              Text(
                'Proceso automático:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('1. Selecciona un archivo (PDF, WAV o ZIP)'),
              Text('2. La app procesa y detecta los audios'),
              Text('3. Etiqueta cada audio con la información médica'),
              Text('4. Los datos se suben automáticamente a S3'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
