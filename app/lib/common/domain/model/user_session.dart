import 'package:equatable/equatable.dart';

class UserSession extends Equatable {
  final String userId;
  final String email;
  final String fullName;
  final String token;

  const UserSession({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.token,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'fullName': fullName,
        'token': token,
      };

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
        userId: json['userId'] as String? ?? '',
        email: json['email'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        token: json['token'] as String? ?? '',
      );

  @override
  List<Object?> get props => [userId, email, fullName, token];
}
