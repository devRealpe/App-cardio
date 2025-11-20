// ============================================================================
// lib/presentation/blocs/upload/upload_bloc.dart
// ============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'upload_event.dart';
import 'upload_state.dart';

/// BLoC para manejar el estado de subida de archivos
/// Este BLoC es principalmente para UI, el trabajo real lo hace FormularioBloc
class UploadBloc extends Bloc<UploadEvent, UploadState> {
  UploadBloc() : super(UploadInitial()) {
    on<UpdateUploadProgressEvent>(_onUpdateProgress);
    on<ResetUploadEvent>(_onReset);
  }

  void _onUpdateProgress(
    UpdateUploadProgressEvent event,
    Emitter<UploadState> emit,
  ) {
    if (event.progress >= 1.0) {
      emit(UploadCompleted());
    } else {
      emit(UploadInProgress(
        progress: event.progress,
        status: event.status,
      ));
    }
  }

  void _onReset(
    ResetUploadEvent event,
    Emitter<UploadState> emit,
  ) {
    emit(UploadInitial());
  }
}
