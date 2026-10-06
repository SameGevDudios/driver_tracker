import 'package:dio/dio.dart';
import 'package:driver_tracker/common/api/api_constants.dart';
import 'package:driver_tracker/feature/auth/data/dto/request/login_request_dto.dart';
import 'package:driver_tracker/feature/auth/data/dto/request/register_request_dto.dart';
import 'package:driver_tracker/feature/auth/data/dto/response/auth_response_dto.dart';

abstract class AuthDatasource {
  Future<AuthResponseDto> login(LoginRequestDto request);
  Future<AuthResponseDto> register(RegisterRequestDto request);
  Future<AuthResponseDto> getProfile();
}

class AuthRemoteDatasource implements AuthDatasource {
  final Dio _dio;

  AuthRemoteDatasource({required Dio dio}) : _dio = dio;

  @override
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );
    return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: request.toJson(),
    );
    return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseDto> getProfile() async {
    final response = await _dio.get(ApiConstants.profile);
    return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
  }
}
