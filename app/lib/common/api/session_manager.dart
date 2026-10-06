import 'package:driver_tracker/common/domain/model/user_session.dart';

abstract class SessionManager {
  Future<void> saveSession(UserSession session);
  Future<UserSession?> getSession();
  Future<String?> getToken();
  Future<bool> hasActiveSession();
  Future<void> clearSession();
}
