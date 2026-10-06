import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_tracker/common/config/app_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppConfig Tests', () {
    test('Fallback to defaults when asset is missing or throws', () async {
      final config = await AppConfig.load(envPath: 'non_existent_env.json');
      expect(config.apiBaseUrl, equals('http://localhost:8080/api'));
      expect(config.useMock, isFalse);
      expect(config.connectTimeout.inSeconds, equals(10));
      expect(config.receiveTimeout.inSeconds, equals(10));
    });

    test('Parses JSON configuration correctly and removes trailing slash', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        final String assetKey = utf8.decode(message!.buffer.asUint8List());
        if (assetKey.contains('custom_env.json')) {
          final jsonContent = json.encode({
            'apiBaseUrl': 'https://custom-api.example.com/api/', // Note trailing slash
            'useMock': true,
            'connectTimeoutMs': 15000,
            'receiveTimeoutMs': 20000,
          });
          final bytes = utf8.encode(jsonContent);
          final buffer = Uint8List.fromList(bytes).buffer;
          return ByteData.view(buffer);
        }
        return null;
      });

      final config = await AppConfig.load(envPath: 'env/custom_env.json');
      // Trailing slash should be stripped
      expect(config.apiBaseUrl, equals('https://custom-api.example.com/api'));
      expect(config.useMock, isTrue);
      expect(config.connectTimeout.inMilliseconds, equals(15000));
      expect(config.receiveTimeout.inMilliseconds, equals(20000));
    });

    test('Safely handles string booleans and num timeouts in JSON', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        final String assetKey = utf8.decode(message!.buffer.asUint8List());
        if (assetKey.contains('string_types.json')) {
          final jsonContent = json.encode({
            'apiBaseUrl': 'http://10.0.2.2:8080/api',
            'useMock': 'TRUE', // String boolean
            'connectTimeoutMs': 12000.0, // Floating point num
            'receiveTimeoutMs': 18000,
          });
          final bytes = utf8.encode(jsonContent);
          final buffer = Uint8List.fromList(bytes).buffer;
          return ByteData.view(buffer);
        }
        return null;
      });

      final config = await AppConfig.load(envPath: 'env/string_types.json');
      expect(config.apiBaseUrl, equals('http://10.0.2.2:8080/api'));
      expect(config.useMock, isTrue);
      expect(config.connectTimeout.inMilliseconds, equals(12000));
      expect(config.receiveTimeout.inMilliseconds, equals(18000));
    });
  });
}
