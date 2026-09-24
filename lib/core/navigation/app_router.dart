import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dailycart/core/constants/app_routes.dart';
import 'package:dailycart/core/theme/app_colors.dart';
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
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0.04, 0.0),
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
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: const _FloatingGlassDock(),
    );
  }
}

class _FloatingGlassDock extends StatelessWidget {
  const _FloatingGlassDock();

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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    const navItems = [
      _NavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: 'Home',
        route: AppRoutes.home,
      ),
      _NavItem(
        icon: Icons.checklist_rtl_rounded,
        selectedIcon: Icons.checklist_rounded,
        label: 'Lists',
        route: AppRoutes.lists,
      ),
      _NavItem(
        icon: Icons.history_rounded,
        selectedIcon: Icons.history_edu_rounded,
        label: 'History',
        route: AppRoutes.history,
      ),
      _NavItem(
        icon: Icons.insights_rounded,
        selectedIcon: Icons.analytics_rounded,
        label: 'Insights',
        route: AppRoutes.analytics,
      ),
      _NavItem(
        icon: Icons.tune_rounded,
        selectedIcon: Icons.tune_rounded,
        label: 'Settings',
        route: AppRoutes.settings,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 66,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xD9121929)
                    : const Color(0xE6FFFFFF),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: isDark
                      ? const Color(0x2EFFFFFF)
                      : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.06),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(navItems.length, (i) {
                  final item = navItems[i];
                  final isSelected = idx == i;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (idx != i) {
                          HapticFeedback.lightImpact();
                          context.go(item.route);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : AppColors.primaryLight.withValues(alpha: 0.14))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              scale: isSelected ? 1.1 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutBack,
                              child: Icon(
                                isSelected ? item.selectedIcon : item.icon,
                                size: 22,
                                color: isSelected
                                    ? (isDark
                                        ? AppColors.primaryNeon
                                        : AppColors.primary)
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? (isDark
                                        ? AppColors.primaryNeon
                                        : AppColors.primary)
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
}
