import '../../../../common/api/session_manager.dart';
import '../../../../common/domain/model/user_session.dart';
import '../../domain/model/auth_user.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../dto/request/login_request_dto.dart';
import '../dto/request/register_request_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _datasource;
  final SessionManager _sessionManager;

  AuthRepositoryImpl({
    required AuthDatasource datasource,
    required SessionManager sessionManager,
  })  : _datasource = datasource,
        _sessionManager = sessionManager;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final responseDto = await _datasource.login(
      LoginRequestDto(email: email, password: password),
    );

    final user = responseDto.toDomain();

    await _sessionManager.saveSession(
      UserSession(
        userId: user.id,
        email: user.email,
        fullName: user.fullName,
        token: user.token,
      ),
    );

    return user;
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final responseDto = await _datasource.register(
      RegisterRequestDto(email: email, password: password, fullName: fullName),
    );

    final user = responseDto.toDomain();

    await _sessionManager.saveSession(
      UserSession(
        userId: user.id,
        email: user.email,
        fullName: user.fullName,
        token: user.token,
      ),
    );

    return user;
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final session = await _sessionManager.getSession();
    if (session == null) return null;
    return AuthUser(
      id: session.userId,
      email: session.email,
      fullName: session.fullName,
      token: session.token,
    );
  }

  @override
  Future<void> logout() async {
    await _sessionManager.clearSession();
  }
}
