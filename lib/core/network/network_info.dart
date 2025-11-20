// lib/core/network/network_info.dart
// VERSIÓN COMPATIBLE CON WEB - Sin peticiones HTTP que causen CORS

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

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

  // Cache de estado de conectividad (válido por 10 segundos)
  DateTime? _lastCheck;
  bool? _cachedConnectionState;
  static const Duration _cacheValidity = Duration(seconds: 10);

  NetworkInfoImpl({
    required this.connectivity,
  });

  @override
  Future<bool> get isConnected async {
    // En web, simplificamos la lógica
    if (kIsWeb) {
      return _checkConnectivityWeb();
    }

    // En móvil, usamos la lógica original pero sin peticiones HTTP
    return _checkConnectivityMobile();
  }

  @override
  Future<ConnectionQuality> get connectionQuality async {
    final hasConnection = await isConnected;

    if (!hasConnection) {
      return ConnectionQuality.none;
    }

    // En web, asumimos buena calidad si hay conexión
    if (kIsWeb) {
      return ConnectionQuality.good;
    }

    // En móvil, verificar el tipo de conexión
    final connectivityResults = await connectivity.checkConnectivity();

    if (connectivityResults.contains(ConnectivityResult.wifi) ||
        connectivityResults.contains(ConnectivityResult.ethernet)) {
      return ConnectionQuality.excellent;
    } else if (connectivityResults.contains(ConnectivityResult.mobile)) {
      return ConnectionQuality.good;
    } else {
      return ConnectionQuality.poor;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.asyncMap((_) async {
      return await isConnected;
    });
  }

  /// Verificación de conectividad para WEB
  Future<bool> _checkConnectivityWeb() async {
    // Retornar cache si es válido
    if (_lastCheck != null &&
        DateTime.now().difference(_lastCheck!) < _cacheValidity) {
      return _cachedConnectionState ?? true;
    }

    try {
      final connectivityResults = await connectivity.checkConnectivity();

      // En web, si connectivity_plus no reporta "none", asumimos que hay conexión
      final hasConnection =
          !connectivityResults.contains(ConnectivityResult.none);

      _updateCache(hasConnection);
      return hasConnection;
    } catch (e) {
      // En caso de error, asumimos que hay conexión en web
      // ya que el usuario está navegando
      _updateCache(true);
      return true;
    }
  }

  /// Verificación de conectividad para MÓVIL
  Future<bool> _checkConnectivityMobile() async {
    // Retornar cache si es válido
    if (_lastCheck != null &&
        DateTime.now().difference(_lastCheck!) < _cacheValidity) {
      return _cachedConnectionState ?? false;
    }

    try {
      final connectivityResults = await connectivity.checkConnectivity();

      final hasConnection =
          !connectivityResults.contains(ConnectivityResult.none);

      _updateCache(hasConnection);
      return hasConnection;
    } catch (e) {
      _updateCache(false);
      return false;
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
