import '../model/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> login({required String email, required String password});
  Future<AuthUser> register({required String email, required String password, required String fullName});
  Future<AuthUser?> getCurrentUser();
  Future<void> logout();
}
