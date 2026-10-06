import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppConfig {
  final String apiBaseUrl;
  final bool useMock;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final String environment;

  const AppConfig({
    required this.apiBaseUrl,
    required this.useMock,
    required this.connectTimeout,
    required this.receiveTimeout,
    this.environment = 'development',
  });

  static AppConfig? _instance;
  static AppConfig get instance {
    if (_instance == null) {
      throw StateError('AppConfig is not initialized. Call AppConfig.load() before using it.');
    }
    return _instance!;
  }

  static Future<AppConfig> load({String? envPath}) async {
    const defineEnv = String.fromEnvironment('ENV', defaultValue: 'development');
    final targetPath = envPath ?? 'env/$defineEnv.json';

    Map<String, dynamic> jsonData = {};

    try {
      final jsonString = await rootBundle.loadString(targetPath);
      jsonData = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[AppConfig] Notice: Could not load $targetPath, falling back to defaults/defines. ($e)',
        );
      }
    }

    const defineApiUrl = String.fromEnvironment('API_BASE_URL');
    String rawUrl = defineApiUrl.isNotEmpty
        ? defineApiUrl
        : (jsonData['apiBaseUrl'] as String? ?? 'http://localhost:8080/api');

    if (rawUrl.endsWith('/')) {
      rawUrl = rawUrl.substring(0, rawUrl.length - 1);
    }

    final bool useMock;
    if (const bool.hasEnvironment('USE_MOCK')) {
      useMock = const bool.fromEnvironment('USE_MOCK');
    } else if (jsonData.containsKey('useMock')) {
      final val = jsonData['useMock'];
      if (val is bool) {
        useMock = val;
      } else if (val is String) {
        useMock = val.toLowerCase() == 'true' || val == '1';
      } else {
        useMock = false;
      }
    } else {
      useMock = false;
    }

    const defineConnectTimeout = int.fromEnvironment('CONNECT_TIMEOUT_MS', defaultValue: 0);
    final connectTimeoutMs = defineConnectTimeout > 0
        ? defineConnectTimeout
        : ((jsonData['connectTimeoutMs'] as num?)?.toInt() ?? 10000);

    const defineReceiveTimeout = int.fromEnvironment('RECEIVE_TIMEOUT_MS', defaultValue: 0);
    final receiveTimeoutMs = defineReceiveTimeout > 0
        ? defineReceiveTimeout
        : ((jsonData['receiveTimeoutMs'] as num?)?.toInt() ?? 10000);

    _instance = AppConfig(
      apiBaseUrl: rawUrl,
      useMock: useMock,
      connectTimeout: Duration(milliseconds: connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: receiveTimeoutMs),
      environment: defineEnv,
    );

    if (kDebugMode) {
      debugPrint('[AppConfig] Initialized ($defineEnv): apiBaseUrl=$rawUrl, useMock=$useMock');
    }

    return _instance!;
  }
}
