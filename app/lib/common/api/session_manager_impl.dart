import 'dart:convert';
import 'package:driver_tracker/common/domain/model/user_session.dart';
import 'package:driver_tracker/common/storage/secure_storage_service.dart';
import 'package:driver_tracker/common/storage/storage_keys.dart';
import 'session_manager.dart';

class SessionManagerImpl implements SessionManager {
  final SecureStorageService _storageService;
  UserSession? _cachedSession;

  SessionManagerImpl({required SecureStorageService storageService})
      : _storageService = storageService;

  @override
  Future<void> saveSession(UserSession session) async {
    _cachedSession = session;
    await _storageService.write(StorageKeys.sessionKey, json.encode(session.toJson()));
    await _storageService.write(StorageKeys.authToken, session.token);
  }

  @override
  Future<UserSession?> getSession() async {
    if (_cachedSession != null) {
      return _cachedSession;
    }
    final raw = await _storageService.read(StorageKeys.sessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final Map<String, dynamic> data = json.decode(raw);
      _cachedSession = UserSession.fromJson(data);
      return _cachedSession;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getToken() async {
    if (_cachedSession != null) {
      return _cachedSession!.token;
    }
    return await _storageService.read(StorageKeys.authToken);
  }

  @override
  Future<bool> hasActiveSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> clearSession() async {
    _cachedSession = null;
    await _storageService.delete(StorageKeys.sessionKey);
    await _storageService.delete(StorageKeys.authToken);
  }
}
