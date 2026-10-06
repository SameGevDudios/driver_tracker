import '../../../domain/model/auth_user.dart';

class AuthResponseDto {
  final String token;
  final String userId;
  final String email;
  final String fullName;

  const AuthResponseDto({
    required this.token,
    required this.userId,
    required this.email,
    required this.fullName,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) => AuthResponseDto(
        token: json['token'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        email: json['email'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
      );

  AuthUser toDomain() => AuthUser(
        id: userId,
        email: email,
        fullName: fullName,
        token: token,
      );
}
