// lib/core/network/network_info.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

/// Contrato para verificar el estado de la red
abstract class NetworkInfo {
  /// Verifica si hay conexión a Internet real (no solo conectividad)
  Future<bool> get isConnected;

  /// Verifica la calidad de la conexión
  Future<ConnectionQuality> get connectionQuality;

  /// Stream para monitorear cambios en la conectividad
  Stream<bool> get onConnectivityChanged;
}

/// Calidad de la conexión de red
enum ConnectionQuality {
  excellent, // < 100ms
  good, // 100-300ms
  poor, // 300-1000ms
  veryPoor, // > 1000ms
  none // Sin conexión
}

/// Implementación de NetworkInfo
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  final http.Client httpClient;

  // URLs de respaldo para verificar conectividad real
  static const List<String> _checkUrls = [
    'https://www.google.com',
    'https://www.cloudflare.com',
    'https://1.1.1.1',
  ];

  // Timeout para verificaciones rápidas
  static const Duration _quickCheckTimeout = Duration(seconds: 5);
  static const Duration _qualityCheckTimeout = Duration(seconds: 3);

  // Cache de estado de conectividad (válido por 10 segundos)
  DateTime? _lastCheck;
  bool? _cachedConnectionState;
  static const Duration _cacheValidity = Duration(seconds: 10);

  NetworkInfoImpl({
    required this.connectivity,
    required this.httpClient,
  });

  @override
  Future<bool> get isConnected async {
    // Retornar cache si es válido
    if (_lastCheck != null &&
        DateTime.now().difference(_lastCheck!) < _cacheValidity) {
      return _cachedConnectionState ?? false;
    }

    // 1. Verificación rápida de conectividad local
    final connectivityResults = await connectivity.checkConnectivity();

    if (connectivityResults.contains(ConnectivityResult.none)) {
      _updateCache(false);
      return false;
    }

    // 2. Verificación real de Internet (ping a múltiples servidores)
    final hasInternet = await _verifyInternetAccess();
    _updateCache(hasInternet);

    return hasInternet;
  }

  @override
  Future<ConnectionQuality> get connectionQuality async {
    final hasConnection = await isConnected;

    if (!hasConnection) {
      return ConnectionQuality.none;
    }

    // Medir latencia con ping
    final latency = await _measureLatency();

    if (latency == null) {
      return ConnectionQuality.none;
    } else if (latency < 100) {
      return ConnectionQuality.excellent;
    } else if (latency < 300) {
      return ConnectionQuality.good;
    } else if (latency < 1000) {
      return ConnectionQuality.poor;
    } else {
      return ConnectionQuality.veryPoor;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.asyncMap((_) async {
      return await isConnected;
    });
  }

  /// Verifica acceso real a Internet intentando conectar a múltiples URLs
  Future<bool> _verifyInternetAccess() async {
    // Intentar con múltiples URLs por si alguna está bloqueada
    for (final url in _checkUrls) {
      try {
        final result = await _checkSingleUrl(url);
        if (result) {
          return true; // Si alguna funciona, hay Internet
        }
      } catch (_) {
        // Continuar con la siguiente URL
        continue;
      }
    }

    return false; // Ninguna URL funcionó
  }

  /// Verifica una URL específica
  Future<bool> _checkSingleUrl(String url) async {
    try {
      final response =
          await httpClient.head(Uri.parse(url)).timeout(_quickCheckTimeout);

      return response.statusCode == 200 ||
          response.statusCode == 301 ||
          response.statusCode == 302;
    } on TimeoutException {
      return false;
    } on SocketException {
      return false;
    } on http.ClientException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Mide la latencia de la conexión
  Future<int?> _measureLatency() async {
    try {
      final stopwatch = Stopwatch()..start();

      await httpClient
          .head(Uri.parse(_checkUrls.first))
          .timeout(_qualityCheckTimeout);

      stopwatch.stop();
      return stopwatch.elapsedMilliseconds;
    } catch (_) {
      return null;
    }
  }

  /// Actualiza el cache de estado de conexión
  void _updateCache(bool isConnected) {
    _lastCheck = DateTime.now();
    _cachedConnectionState = isConnected;
  }

  /// Limpia el cache (útil para forzar una nueva verificación)
  void clearCache() {
    _lastCheck = null;
    _cachedConnectionState = null;
  }
}
