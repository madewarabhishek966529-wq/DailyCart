import 'package:flutter/material.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/core/animations/app_animations.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.action,
  });

  final String message;
  final String? title;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: FadeSlideTransition(
          duration: const Duration(milliseconds: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              AppColors.primary.withValues(alpha: 0.2),
                              AppColors.secondary.withValues(alpha: 0.08),
                            ]
                          : [
                              AppColors.primaryLight.withValues(alpha: 0.15),
                              AppColors.primary.withValues(alpha: 0.05),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: isDark
                          ? AppColors.primaryLight.withValues(alpha: 0.25)
                          : AppColors.primary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 36,
                      color: isDark
                          ? AppColors.primaryLight
                          : AppColors.primary,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              if (title != null) ...[
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[
                const SizedBox(height: 24),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
