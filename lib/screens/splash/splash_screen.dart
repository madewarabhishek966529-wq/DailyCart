import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dailycart/core/constants/app_constants.dart';
import 'package:dailycart/core/constants/app_routes.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/providers/database_provider.dart';
import 'package:dailycart/providers/settings_provider.dart';
import 'package:dailycart/widgets/common/app_logo_widget.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _pulseController;
  late final AnimationController _textController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _pulseAnimation;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textFade;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 1. Logo entry (elastic bounce)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    // 2. Pulse aura ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 3. Text slide up and fade in
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );
    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _startSequence();
  }

  void _startSequence() {
    _logoController.forward().then((_) {
      if (mounted) {
        _textController.forward();
      }
    });

    _timer = Timer(const Duration(milliseconds: 1200), () async {
      if (!mounted) return;
      await Future.wait([
        ref.read(databaseProvider.future).catchError((_) => null as dynamic),
        ref.read(settingsProvider.future).catchError((_) => null as dynamic),
      ]);

      if (!mounted) return;

      final settings = ref.read(settingsProvider).valueOrNull;
      final onboardingDone = settings?.onboardingDone ?? false;

      if (onboardingDone) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _logoController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo with radiating pulse aura
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120 * _pulseAnimation.value,
                      height: 120 * _pulseAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isDark
                                ? AppColors.primaryNeon
                                : AppColors.primary)
                            .withValues(alpha: 
                          (0.18 / _pulseAnimation.value).clamp(0.04, 0.2),
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: const AppLogoWidget(size: 96, showShadow: true),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // Text section
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primaryNeon.withValues(alpha: 0.12)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.primaryNeon.withValues(alpha: 0.25)
                              : AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        AppConstants.appTagline,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: isDark
                              ? AppColors.primaryNeon
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
