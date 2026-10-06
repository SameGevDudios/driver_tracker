import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String token;

  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.token,
  });

  @override
  List<Object?> get props => [id, email, fullName, token];
}
