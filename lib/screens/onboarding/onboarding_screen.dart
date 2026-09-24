import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dailycart/core/constants/app_routes.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/core/animations/app_animations.dart';
import 'package:dailycart/providers/settings_provider.dart';
import 'package:dailycart/widgets/common/bouncy_tap.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      icon: Icons.checklist_rtl_rounded,
      title: 'Plan Your Shopping',
      description:
          'Build organized grocery lists in seconds. Group items by category and prepare effortlessly before you leave home.',
      gradient: AppColors.primaryGradient,
    ),
    _OnboardingPageData(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Real-Time Budget HUD',
      description:
          'Estimate your total cart cost beforehand and set budgets to avoid any surprises at the checkout counter.',
      gradient: LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _OnboardingPageData(
      icon: Icons.check_circle_rounded,
      title: 'Effortless In-Store Mode',
      description:
          'Check off items with single-tap spring actions, adjust quantities on the fly, and repeat previous trips in one tap.',
      gradient: AppColors.emeraldNeonGradient,
    ),
  ];

  Future<void> _finishOnboarding() async {
    HapticFeedback.mediumImpact();
    await ref.read(settingsProvider.notifier).setOnboardingDone();
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isLastPage)
                    BouncyTap(
                      onTap: _finishOnboarding,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 34),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: FadeSlideTransition(
                      duration: const Duration(milliseconds: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: page.gradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              page.icon,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 48),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom row with page indicators and button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? (isDark
                                  ? AppColors.primaryNeon
                                  : AppColors.primary)
                              : (isDark ? Colors.white24 : Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  BouncyTap(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (isLastPage) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: isLastPage
                            ? AppColors.emeraldNeonGradient
                            : AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLastPage ? 'Get Started' : 'Continue',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });

  final IconData icon;
  final String title;
  final String description;
  final LinearGradient gradient;
}
