import 'package:dio/dio.dart';
import 'session_manager.dart';

class AuthInterceptor extends Interceptor {
  final SessionManager _sessionManager;

  AuthInterceptor({required SessionManager sessionManager})
      : _sessionManager = sessionManager;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _sessionManager.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Clear invalid session when 401 received
      _sessionManager.clearSession();
    }
    super.onError(err, handler);
  }
}
