// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

import 'amplifyconfiguration.dart';
import 'injection_container.dart' as di;
import 'presentation/theme/app_theme.dart';
import 'presentation/pages/formulario/formulario_page.dart';
import 'presentation/blocs/config/config_bloc.dart';
import 'presentation/blocs/config/config_event.dart';

/// Punto de entrada principal de la aplicación
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Amplify
  await _initializeAmplify();

  // Inicializar inyección de dependencias
  await di.init();

  runApp(const MyApp());
}

/// Configura e inicializa Amplify con Auth y Storage
Future<void> _initializeAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    final storage = AmplifyStorageS3();

    await Amplify.addPlugins([auth, storage]);
    await Amplify.configure(amplifyconfig);

    safePrint('Amplify configurado exitosamente');
  } catch (e) {
    safePrint('Error al configurar Amplify: $e');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // Providers globales de BLoC
      providers: [
        // BLoC de configuración (carga el JSON una sola vez)
        BlocProvider<ConfigBloc>(
          create: (context) =>
              di.sl<ConfigBloc>()..add(CargarConfiguracionEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'ASCS - Etiquetado Cardíaco',
        debugShowCheckedModeBanner: false,

        // Tema personalizado desde archivo separado
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,

        // Página principal
        home: const FormularioPage(),
      ),
    );
  }
}
