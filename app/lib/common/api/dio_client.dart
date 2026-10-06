import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:driver_tracker/common/config/app_config.dart';
import 'auth_interceptor.dart';
import 'session_manager.dart';

class DioClient {
  final Dio dio;
  final CookieJar cookieJar;

  DioClient._({
    required this.dio,
    required this.cookieJar,
  });

  factory DioClient({
    required AppConfig config,
    required SessionManager sessionManager,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final cookieJar = CookieJar();

    dio.interceptors.addAll([
      CookieManager(cookieJar),
      AuthInterceptor(sessionManager: sessionManager),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    ]);

    return DioClient._(
      dio: dio,
      cookieJar: cookieJar,
    );
  }
}
