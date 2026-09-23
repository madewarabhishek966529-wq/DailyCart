import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dailycart/core/constants/app_routes.dart';
import 'package:dailycart/screens/splash/splash_screen.dart';
import 'package:dailycart/screens/onboarding/onboarding_screen.dart';
import 'package:dailycart/screens/home/home_screen.dart';
import 'package:dailycart/screens/lists/lists_screen.dart';
import 'package:dailycart/screens/history/history_screen.dart';
import 'package:dailycart/screens/analytics/analytics_screen.dart';
import 'package:dailycart/screens/settings/settings_screen.dart';

import 'package:dailycart/screens/shopping/shopping_screen.dart';
import 'package:dailycart/screens/templates/templates_screen.dart';
import 'package:dailycart/screens/backup/backup_screen.dart';

final _shellKey = GlobalKey<NavigatorState>();

CustomTransitionPage<T> _buildFadeSlidePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0.06, 0.0),
        end: Offset.zero,
      ).animate(curve);
      final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curve);

      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(opacity: fadeAnimation, child: child),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => _buildFadeSlidePage(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/lists/:listId/shopping',
        pageBuilder: (context, state) {
          final listId =
              int.tryParse(state.pathParameters['listId'] ?? '') ?? 0;
          return _buildFadeSlidePage(
            key: state.pageKey,
            child: ShoppingScreen(listId: listId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.templates,
        pageBuilder: (context, state) => _buildFadeSlidePage(
          key: state.pageKey,
          child: const TemplatesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.backup,
        pageBuilder: (context, state) => _buildFadeSlidePage(
          key: state.pageKey,
          child: const BackupScreen(),
        ),
      ),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.lists,
            builder: (context, state) => const ListsScreen(),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.analytics,
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, bottomNavigationBar: _BottomNav());
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    int idx = 0;
    if (location.startsWith('/lists')) {
      idx = 1;
    } else if (location.startsWith('/history')) {
      idx = 2;
    } else if (location.startsWith('/analytics')) {
      idx = 3;
    } else if (location.startsWith('/settings')) {
      idx = 4;
    }

    return NavigationBar(
      selectedIndex: idx,
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            context.go(AppRoutes.home);
            break;
          case 1:
            context.go(AppRoutes.lists);
            break;
          case 2:
            context.go(AppRoutes.history);
            break;
          case 3:
            context.go(AppRoutes.analytics);
            break;
          case 4:
            context.go(AppRoutes.settings);
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt),
          label: 'Lists',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'History',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Analytics',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
