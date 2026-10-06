import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../feature/auth/presentation/widget/auth_page.dart';
import '../../feature/profile/presentation/profile_page.dart';
import '../../feature/trips/presentation/widget/trips_diary_page.dart';
import '../api/session_manager.dart';
import 'navigation_routes.dart';
import 'widgets/app_scaffold.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static GoRouter createRouter(SessionManager sessionManager) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: NavigationRoutes.diary,
      routes: [
        GoRoute(
          path: NavigationRoutes.login,
          builder: (context, state) => const AuthPage(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => AppScaffold(child: child),
          routes: [
            GoRoute(
              path: NavigationRoutes.diary,
              builder: (context, state) => const TripsDiaryPage(),
            ),
            GoRoute(
              path: NavigationRoutes.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    );
  }
}
