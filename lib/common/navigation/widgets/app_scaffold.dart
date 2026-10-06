import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../navigation_routes.dart';
import 'bottom_nav_bar.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({
    super.key,
    required this.child,
  });

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(NavigationRoutes.profile)) {
      return 1;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(NavigationRoutes.diary);
        break;
      case 1:
        context.go(NavigationRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthScreen = GoRouterState.of(context).matchedLocation == NavigationRoutes.login;

    if (isAuthScreen) {
      return Scaffold(
        body: SafeArea(child: child),
      );
    }

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}
