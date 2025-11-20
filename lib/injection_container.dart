// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

// Core
import 'core/network/network_info.dart';

// Data Sources - Existentes
import 'data/datasources/local/config_local_datasource.dart';
import 'data/datasources/remote/aws_s3_remote_datasource.dart';

// Data Sources - NUEVOS para PDF/ZIP
import 'data/datasources/local/pdf_datasource.dart';
import 'data/datasources/local/zip_datasource.dart';
import 'data/datasources/remote/download_datasource.dart';

// Repositories - Existentes
import 'data/repositories/config_repository_impl.dart';
import 'data/repositories/formulario_repository_impl.dart';
import 'domain/repositories/config_repository.dart';
import 'domain/repositories/formulario_repository.dart';

// Repositories - NUEVOS
import 'data/repositories/archivo_repository_impl.dart';
import 'domain/repositories/archivo_repository.dart';

// Use Cases - Existentes
import 'domain/usecases/config/obtener_hospitales_usecase.dart';
import 'domain/usecases/config/obtener_consultorios_por_hospital_usecase.dart';
import 'domain/usecases/config/obtener_focos_usecase.dart';
import 'domain/usecases/enviar_formulario_usecase.dart';
import 'domain/usecases/generar_nombre_archivo_usecase.dart';

// Use Cases - NUEVOS para PDF/ZIP
import 'domain/usecases/extraer_link_pdf_usecase.dart';
import 'domain/usecases/descargar_archivo_usecase.dart';
import 'domain/usecases/descomprimir_zip_usecase.dart';
import 'domain/usecases/procesar_lote_audios_usecase.dart';

// BLoCs - Existentes
import 'presentation/blocs/config/config_bloc.dart';
import 'presentation/blocs/formulario/formulario_bloc.dart';
import 'presentation/blocs/upload/upload_bloc.dart';

// BLoCs - NUEVOS
import 'presentation/blocs/procesamiento/procesamiento_bloc.dart';

final sl = GetIt.instance;

/// Inicializa todas las dependencias de la aplicación
Future<void> init() async {
  //! =========================================================================
  //! Core
  //! =========================================================================

  // Network Info
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      connectivity: sl(),
    ),
  );

  //! =========================================================================
  //! Features - Config (Existente)
  //! =========================================================================

  // BLoC
  sl.registerFactory(
    () => ConfigBloc(
      configRepository: sl(),
      obtenerConsultoriosUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => ObtenerHospitalesUseCase(repository: sl()));
  sl.registerLazySingleton(
    () => ObtenerConsultoriosPorHospitalUseCase(repository: sl()),
  );
  sl.registerLazySingleton(() => ObtenerFocosUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<ConfigRepository>(
    () => ConfigRepositoryImpl(localDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<ConfigLocalDataSource>(
    () => ConfigLocalDataSourceImpl(),
  );

  //! =========================================================================
  //! Features - Formulario (Existente)
  //! =========================================================================

  // BLoC
  sl.registerFactory(
    () => FormularioBloc(
      enviarFormularioUseCase: sl(),
      generarNombreArchivoUseCase: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerFactory(() => UploadBloc());

  // Use Cases
  sl.registerLazySingleton(() => EnviarFormularioUseCase(repository: sl()));
  sl.registerLazySingleton(() => GenerarNombreArchivoUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<FormularioRepository>(
    () => FormularioRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AwsS3RemoteDataSource>(
    () => AwsS3RemoteDataSourceImpl(),
  );

  //! =========================================================================
  //! Features - Procesamiento de Archivos (NUEVO)
  //! =========================================================================

  // BLoC
  sl.registerFactory(
    () => ProcesamientoBloc(
      extraerLinkPdfUseCase: sl(),
      descargarArchivoUseCase: sl(),
      descomprimirZipUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => ExtraerLinkPdfUseCase(repository: sl()));
  sl.registerLazySingleton(() => DescargarArchivoUseCase(repository: sl()));
  sl.registerLazySingleton(() => DescomprimirZipUseCase(repository: sl()));
  sl.registerLazySingleton(
    () => ProcesarLoteAudiosUseCase(repository: sl()),
  );

  // Repository
  sl.registerLazySingleton<ArchivoRepository>(
    () => ArchivoRepositoryImpl(
      pdfDataSource: sl(),
      downloadDataSource: sl(),
      zipDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<PdfDataSource>(
    () => PdfDataSourceImpl(),
  );

  sl.registerLazySingleton<DownloadDataSource>(
    () => DownloadDataSourceImpl(httpClient: sl()),
  );

  sl.registerLazySingleton<ZipDataSource>(
    () => ZipDataSourceImpl(),
  );

  //! =========================================================================
  //! External Dependencies
  //! =========================================================================

  // HTTP Client
  sl.registerLazySingleton(() => http.Client());

  // Connectivity
  sl.registerLazySingleton(() => Connectivity());
}
