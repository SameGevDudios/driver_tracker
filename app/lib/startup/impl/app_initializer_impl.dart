import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver_tracker/common/api/dio_client.dart';
import 'package:driver_tracker/common/api/session_manager.dart';
import 'package:driver_tracker/common/api/session_manager_impl.dart';
import 'package:driver_tracker/common/config/app_config.dart';
import 'package:driver_tracker/common/navigation/app_router.dart';
import 'package:driver_tracker/common/storage/secure_storage_service.dart';
import 'package:driver_tracker/feature/auth/data/datasource/auth_mock_datasource.dart';
import 'package:driver_tracker/feature/auth/data/datasource/auth_remote_datasource.dart';
import 'package:driver_tracker/feature/auth/data/repository/auth_repository_impl.dart';
import 'package:driver_tracker/feature/auth/domain/repository/auth_repository.dart';
import 'package:driver_tracker/feature/auth/presentation/logic/auth_bloc/auth_bloc.dart';
import 'package:driver_tracker/feature/auth/presentation/logic/auth_bloc/auth_event.dart';
import 'package:driver_tracker/feature/trips/data/datasource/trips_datasource.dart';
import 'package:driver_tracker/feature/trips/data/datasource/trips_mock_datasource.dart';
import 'package:driver_tracker/feature/trips/data/datasource/trips_remote_datasource.dart';
import 'package:driver_tracker/feature/trips/data/repository/trips_repository_impl.dart';
import 'package:driver_tracker/feature/trips/domain/repository/trips_repository.dart';
import 'package:driver_tracker/startup/api/app_initializer_api.dart';

class AppInitializerImpl implements AppInitializerApi {
  late final AppConfig _config;
  late final SessionManager _sessionManager;
  late final DioClient _dioClient;
  late final AuthRepository _authRepository;
  late final TripsRepository _tripsRepository;

  @override
  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Load environment configuration
    _config = await AppConfig.load();

    // 2. Storage & Session
    final storageService = const SecureStorageService();
    _sessionManager = SessionManagerImpl(storageService: storageService);

    // 3. Dio Client
    _dioClient = DioClient(
      config: _config,
      sessionManager: _sessionManager,
    );

    // 4. Data sources & Repositories
    final AuthDatasource authDatasource = _config.useMock
        ? AuthMockDatasource()
        : AuthRemoteDatasource(dio: _dioClient.dio);

    _authRepository = AuthRepositoryImpl(
      datasource: authDatasource,
      sessionManager: _sessionManager,
    );

    final TripsDatasource tripsDatasource = _config.useMock
        ? TripsMockDatasource()
        : TripsRemoteDatasource(dio: _dioClient.dio);

    _tripsRepository = TripsRepositoryImpl(datasource: tripsDatasource);
  }

  @override
  Widget createRootWidget() {
    final router = AppRouter.createRouter(_sessionManager);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppConfig>.value(value: _config),
        RepositoryProvider<SessionManager>.value(value: _sessionManager),
        RepositoryProvider<DioClient>.value(value: _dioClient),
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<TripsRepository>.value(value: _tripsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(authRepository: _authRepository)..add(AuthCheckRequested()),
          ),
        ],
        child: MaterialApp.router(
          title: 'Дневник смен водителя',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFEAA000), // Taxi Yellow/Gold
              primary: const Color(0xFFD97706),
              secondary: const Color(0xFF1E293B),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF0F172A),
              centerTitle: false,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
          routerConfig: router,
        ),
      ),
    );
  }
}
