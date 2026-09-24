import 'package:flutter/material.dart';
import 'package:dailycart/core/theme/app_colors.dart';

class ProgressBarWidget extends StatelessWidget {
  const ProgressBarWidget({
    super.key,
    required this.value,
    this.height = 10,
    this.gradient,
    this.backgroundColor,
    this.borderRadius = 10,
    this.duration = const Duration(milliseconds: 450),
  });

  final double value;
  final double height;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final double borderRadius;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clamped = value.clamp(0.0, 1.0);

    final defaultBg = isDark
        ? const Color(0xFF1E2638)
        : const Color(0xFFE2E8F0);

    final defaultGradient = clamped >= 1.0
        ? const LinearGradient(
            colors: [AppColors.success, AppColors.primaryNeon],
          )
        : AppColors.emeraldNeonGradient;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        width: double.infinity,
        color: backgroundColor ?? defaultBg,
        child: TweenAnimationBuilder<double>(
          duration: duration,
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0.0, end: clamped),
          builder: (context, animValue, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: animValue,
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient ?? defaultGradient,
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: animValue > 0.1
                      ? [
                          BoxShadow(
                            color: AppColors.primaryNeon.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
