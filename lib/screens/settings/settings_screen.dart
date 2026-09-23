import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:dailycart/core/constants/app_constants.dart';
import 'package:dailycart/core/constants/app_routes.dart';
import 'package:dailycart/core/services/notification_service.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/providers/settings_provider.dart';
import 'package:dailycart/screens/settings/categories_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: settingsAsync.when(
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Appearance Section
              _buildSectionHeader('Appearance', isDark),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE8E8E8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.brightness_6_rounded),
                        title: const Text('Theme Mode'),
                        subtitle: Text(
                          _themeModeLabel(settings.themeMode),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                        trailing: DropdownButton<ThemeMode>(
                          value: settings.themeMode,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text('System'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text('Light'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text('Dark'),
                            ),
                          ],
                          onChanged: (mode) {
                            if (mode != null) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .setThemeMode(mode);
                            }
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.animation_rounded),
                        title: const Text('Reduced Motion'),
                        subtitle: Text(
                          'Minimizes animations for faster UI response',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                        value: settings.reducedMotion,
                        onChanged: (val) {
                          ref
                              .read(settingsProvider.notifier)
                              .setReducedMotion(val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Preferences Section
              _buildSectionHeader('Preferences', isDark),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE8E8E8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.currency_rupee_rounded),
                        title: Text('Currency'),
                        subtitle: Text('Indian Rupee (₹ INR)'),
                        trailing: Icon(Icons.lock_outline, size: 16),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.vibration_rounded),
                        title: const Text('Haptic Feedback'),
                        subtitle: const Text('Vibrate on checkbox and taps'),
                        value: settings.hapticsEnabled,
                        onChanged: (val) {
                          ref.read(settingsProvider.notifier).setHaptics(val);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.category_outlined),
                        title: const Text('Manage Categories'),
                        subtitle: const Text('Add or view grocery categories'),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                        ),
                        onTap: () => CategoriesSheet.show(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.copy_rounded),
                        title: const Text('Shopping Templates'),
                        subtitle: const Text('Weekly & custom templates'),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                        ),
                        onTap: () => context.push(AppRoutes.templates),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notifications Section
              _buildSectionHeader('Notifications', isDark),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE8E8E8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(
                          Icons.notifications_active_outlined,
                        ),
                        title: const Text('Local Notifications'),
                        subtitle: const Text('Shopping and list reminders'),
                        value: settings.notificationsEnabled,
                        onChanged: (val) async {
                          if (val) {
                            await NotificationService.instance
                                .requestPermissions();
                          }
                          await ref
                              .read(settingsProvider.notifier)
                              .setNotifications(val);
                        },
                      ),
                      if (settings.notificationsEnabled) ...[
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.send_rounded),
                          title: const Text('Send Test Reminder'),
                          subtitle: const Text(
                            'Verify notification permissions on your device',
                          ),
                          trailing: TextButton(
                            onPressed: () async {
                              await NotificationService.instance.showReminder(
                                id: 999,
                                title: 'DailyCart Reminder 🛒',
                                body:
                                    'Don’t forget to check your grocery list!',
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Test notification sent!'),
                                  ),
                                );
                              }
                            },
                            child: const Text('Test'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Security & Privacy
              _buildSectionHeader('Security & Privacy', isDark),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE8E8E8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.fingerprint_rounded),
                        title: const Text('App Lock (Biometric / PIN)'),
                        subtitle: const Text(
                          'Require authentication when opening DailyCart',
                        ),
                        value: settings.appLockEnabled,
                        onChanged: (val) async {
                          if (val) {
                            final localAuth = LocalAuthentication();
                            final canAuth =
                                await localAuth.canCheckBiometrics ||
                                await localAuth.isDeviceSupported();
                            if (!canAuth) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Device does not support biometric or PIN authentication.',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                          }
                          await ref
                              .read(settingsProvider.notifier)
                              .setAppLock(val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Data & Backup
              _buildSectionHeader('Data Safety', isDark),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE8E8E8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.backup_outlined),
                        title: const Text('Backup & Restore Data'),
                        subtitle: const Text(
                          'Export JSON/CSV or restore from local backup',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                        ),
                        onTap: () => context.push(AppRoutes.backup),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.restart_alt_rounded),
                        title: const Text('View Onboarding Guide Again'),
                        subtitle: const Text('Show initial setup walkthrough'),
                        onTap: () {
                          context.go(AppRoutes.onboarding);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // About Section
              _buildSectionHeader('About DailyCart', isDark),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE8E8E8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.shopping_cart_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppConstants.appName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Version 1.0.0 (Local-First)',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              color: AppColors.success,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '100% Offline • No Cloud Accounts • Encrypted Local SQLite',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follows device system settings';
      case ThemeMode.light:
        return 'Light theme active';
      case ThemeMode.dark:
        return 'Dark theme active';
    }
  }
}
