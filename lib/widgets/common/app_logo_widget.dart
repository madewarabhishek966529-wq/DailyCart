import 'package:flutter/material.dart';
import 'package:dailycart/core/theme/app_colors.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({
    super.key,
    this.size = 72,
    this.borderRadius,
    this.showShadow = true,
  });

  final double size;
  final double? borderRadius;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? (size * 0.28);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withAlpha(45),
                  blurRadius: size * 0.25,
                  offset: Offset(0, size * 0.1),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          'assets/icons/app_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Elegant fallback if asset fails to load
            return Container(
              color: AppColors.primary,
              child: Center(
                child: Icon(
                  Icons.shopping_cart_rounded,
                  size: size * 0.52,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
