import 'dart:async';
import '../dto/request/login_request_dto.dart';
import '../dto/request/register_request_dto.dart';
import '../dto/response/auth_response_dto.dart';
import 'auth_remote_datasource.dart';

class AuthMockDatasource implements AuthDatasource {
  @override
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Accept demo driver or any valid formatted email/pass
    if (request.password.length < 6) {
      throw Exception('Пароль должен содержать не менее 6 символов');
    }
    return AuthResponseDto(
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'u_driver_mock',
      email: request.email,
      fullName: request.email.startsWith('driver') ? 'Иван Водитель' : 'Водитель Такси',
    );
  }

  @override
  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AuthResponseDto(
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'u_driver_${DateTime.now().millisecondsSinceEpoch}',
      email: request.email,
      fullName: request.fullName,
    );
  }

  @override
  Future<AuthResponseDto> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const AuthResponseDto(
      token: 'mock_token_cached',
      userId: 'u_driver_mock',
      email: 'driver@example.com',
      fullName: 'Иван Водитель',
    );
  }
}
