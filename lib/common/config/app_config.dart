import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfig {
  final String apiBaseUrl;
  final bool useMock;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  const AppConfig({
    required this.apiBaseUrl,
    required this.useMock,
    required this.connectTimeout,
    required this.receiveTimeout,
  });

  static AppConfig? _instance;
  static AppConfig get instance {
    if (_instance == null) {
      throw StateError('AppConfig is not initialized. Call AppConfig.load() before using it.');
    }
    return _instance!;
  }

  static Future<AppConfig> load({String envPath = 'env/development.json'}) async {
    try {
      final jsonString = await rootBundle.loadString(envPath);
      final Map<String, dynamic> data = json.decode(jsonString);
      _instance = AppConfig(
        apiBaseUrl: data['apiBaseUrl'] as String? ?? 'http://localhost:8080/api',
        useMock: data['useMock'] as bool? ?? false,
        connectTimeout: Duration(milliseconds: data['connectTimeoutMs'] as int? ?? 10000),
        receiveTimeout: Duration(milliseconds: data['receiveTimeoutMs'] as int? ?? 10000),
      );
    } catch (_) {
      // Fallback default config
      _instance = const AppConfig(
        apiBaseUrl: 'http://localhost:8080/api',
        useMock: false,
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
      );
    }
    return _instance!;
  }
}
