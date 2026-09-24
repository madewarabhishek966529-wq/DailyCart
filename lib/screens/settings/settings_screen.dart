import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:dailycart/core/constants/app_constants.dart';
import 'package:dailycart/core/constants/app_routes.dart';
import 'package:dailycart/core/services/notification_service.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/core/animations/app_animations.dart';
import 'package:dailycart/providers/settings_provider.dart';
import 'package:dailycart/screens/settings/categories_sheet.dart';
import 'package:dailycart/widgets/common/app_logo_widget.dart';
import 'package:dailycart/widgets/common/bouncy_tap.dart';

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
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: settingsAsync.when(
        data: (settings) {
          return ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              // Appearance Section
              FadeSlideTransition(
                delay: const Duration(milliseconds: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('APPEARANCE', isDark),
                    _buildSettingsCard(
                      isDark: isDark,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildSettingIcon(
                                    icon: Icons.brightness_6_rounded,
                                    color: AppColors.secondary,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Theme Mode',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          _themeModeLabel(settings.themeMode),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppColors.textSecondaryDark
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Segmented theme picker pills
                              Row(
                                children: [
                                  _buildThemePill(
                                    context,
                                    ref,
                                    label: 'System',
                                    icon: Icons.smartphone_rounded,
                                    isSelected: settings.themeMode ==
                                        ThemeMode.system,
                                    mode: ThemeMode.system,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildThemePill(
                                    context,
                                    ref,
                                    label: 'Light',
                                    icon: Icons.light_mode_rounded,
                                    isSelected:
                                        settings.themeMode == ThemeMode.light,
                                    mode: ThemeMode.light,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildThemePill(
                                    context,
                                    ref,
                                    label: 'Dark',
                                    icon: Icons.dark_mode_rounded,
                                    isSelected:
                                        settings.themeMode == ThemeMode.dark,
                                    mode: ThemeMode.dark,
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          secondary: _buildSettingIcon(
                            icon: Icons.animation_rounded,
                            color: AppColors.accentPurple,
                          ),
                          title: const Text(
                            'Reduced Motion',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            'Minimizes animations for faster UI response',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                          value: settings.reducedMotion,
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            ref
                                .read(settingsProvider.notifier)
                                .setReducedMotion(val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Preferences Section
              FadeSlideTransition(
                delay: const Duration(milliseconds: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('PREFERENCES', isDark),
                    _buildSettingsCard(
                      isDark: isDark,
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 2,
                          ),
                          leading: _buildSettingIcon(
                            icon: Icons.currency_rupee_rounded,
                            color: AppColors.accentAmber,
                          ),
                          title: const Text(
                            'Currency',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: const Text(
                            'Indian Rupee (₹ INR)',
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Fixed',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          secondary: _buildSettingIcon(
                            icon: Icons.vibration_rounded,
                            color: AppColors.primaryLight,
                          ),
                          title: const Text(
                            'Haptic Feedback',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: const Text(
                            'Tactile response on checkbox and button taps',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: settings.hapticsEnabled,
                          onChanged: (val) {
                            HapticFeedback.mediumImpact();
                            ref
                                .read(settingsProvider.notifier)
                                .setHaptics(val);
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 2,
                          ),
                          leading: _buildSettingIcon(
                            icon: Icons.category_rounded,
                            color: AppColors.accentCyan,
                          ),
                          title: const Text(
                            'Manage Categories',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: const Text(
                            'Organize aisles and custom categories',
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                          ),
                          onTap: () => CategoriesSheet.show(context),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 2,
                          ),
                          leading: _buildSettingIcon(
                            icon: Icons.copy_rounded,
                            color: AppColors.secondary,
                          ),
                          title: const Text(
                            'Shopping Templates',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: const Text(
                            'Weekly & custom grocery templates',
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                          ),
                          onTap: () => context.push(AppRoutes.templates),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Notifications Section
              FadeSlideTransition(
                delay: const Duration(milliseconds: 160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('NOTIFICATIONS', isDark),
                    _buildSettingsCard(
                      isDark: isDark,
                      children: [
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          secondary: _buildSettingIcon(
                            icon: Icons.notifications_active_rounded,
                            color: AppColors.error,
                          ),
                          title: const Text(
                            'Local Notifications',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: const Text(
                            'Shopping reminders & schedule alerts',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: settings.notificationsEnabled,
                          onChanged: (val) async {
                            HapticFeedback.lightImpact();
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 2,
                            ),
                            leading: _buildSettingIcon(
                              icon: Icons.send_rounded,
                              color: AppColors.primaryLight,
                            ),
                            title: const Text(
                              'Send Test Reminder',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: const Text(
                              'Verify push notification permissions',
                              style: TextStyle(fontSize: 12),
                            ),
                            trailing: BouncyTap(
                              onTap: () async {
                                HapticFeedback.lightImpact();
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
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Test',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Security & Privacy
              FadeSlideTransition(
                delay: const Duration(milliseconds: 220),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('SECURITY & DATA', isDark),
                    _buildSettingsCard(
                      isDark: isDark,
                      children: [
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          secondary: _buildSettingIcon(
                            icon: Icons.fingerprint_rounded,
                            color: AppColors.secondary,
                          ),
                          title: const Text(
                            'App Lock (Biometric / PIN)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: const Text(
                            'Require authentication when launching DailyCart',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: settings.appLockEnabled,
                          onChanged: (val) async {
                            HapticFeedback.lightImpact();
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
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 2,
                          ),
                          leading: _buildSettingIcon(
                            icon: Icons.backup_rounded,
                            color: AppColors.accentCyan,
                          ),
                          title: const Text(
                            'Backup & Restore Data',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: const Text(
                            'Export JSON/CSV or restore from local backup',
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                          ),
                          onTap: () => context.push(AppRoutes.backup),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 2,
                          ),
                          leading: _buildSettingIcon(
                            icon: Icons.restart_alt_rounded,
                            color: AppColors.primaryLight,
                          ),
                          title: const Text(
                            'View Onboarding Guide',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: const Text(
                            'Revisit initial setup walkthrough',
                            style: TextStyle(fontSize: 12),
                          ),
                          onTap: () {
                            context.go(AppRoutes.onboarding);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // About Section
              FadeSlideTransition(
                delay: const Duration(milliseconds: 280),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('ABOUT DAILYCART', isDark),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              AppLogoWidget(
                                size: 52,
                                borderRadius: 14,
                                showShadow: true,
                              ),
                              SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppConstants.appName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Version 1.0.0 • Local-First Suite',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.shield_rounded,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '100% Offline • Private SQLite • Zero Cloud Tracking',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
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
                  ],
                ),
              ),
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
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingIcon({required IconData icon, required Color color}) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: Icon(icon, color: color, size: 18)),
    );
  }

  Widget _buildThemePill(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required ThemeMode mode,
    required bool isDark,
  }) {
    return Expanded(
      child: BouncyTap(
        scaleFactor: 0.94,
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(settingsProvider.notifier).setThemeMode(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? AppColors.primaryNeon.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.12))
                : (isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.primaryNeon : AppColors.primary)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? (isDark ? AppColors.primaryNeon : AppColors.primary)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? AppColors.primaryNeon : AppColors.primary)
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
