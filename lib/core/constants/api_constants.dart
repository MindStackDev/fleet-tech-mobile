import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  // Base API configuration
  // For Android emulator: 10.0.2.2:8000
  // For iOS simulator / Web / Desktop: 127.0.0.1:8000
  static const String androidEmulatorHost = 'http://10.0.2.2:8000/api/v1';
  static const String localHost = 'http://127.0.0.1:8000/api/v1';

  // Configurable base URL
  static String get baseUrl {
    if (kIsWeb) return localHost;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidEmulatorHost;
    }
    return localHost;
  }

  // Auth endpoints (Laravel Sanctum)
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Core endpoints
  static const String workOrders = '/work-orders';
  static const String vehicles = '/vehicles';
  static const String devices = '/devices';
  static const String interventions = '/interventions';
  static const String sync = '/sync';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
