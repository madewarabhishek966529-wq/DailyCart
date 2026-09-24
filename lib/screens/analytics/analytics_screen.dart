import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/core/utils/format_utils.dart';
import 'package:dailycart/core/animations/app_animations.dart';
import 'package:dailycart/models/shopping_history_model.dart';
import 'package:dailycart/providers/category_provider.dart';
import 'package:dailycart/providers/frequent_item_provider.dart';
import 'package:dailycart/providers/history_provider.dart';
import 'package:dailycart/widgets/common/empty_state_widget.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final frequentItemsAsync = ref.watch(frequentItemsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Spending & Insights',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: historyAsync.when(
        data: (historyList) {
          if (historyList.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.insights_rounded,
              title: 'No Spending Insights Yet',
              message:
                  'Complete your grocery shopping trips to view spending analytics, monthly trends, and charts.',
            );
          }

          final totalSpent = historyList.fold<double>(
            0.0,
            (sum, h) => sum + h.totalAmount,
          );
          final tripCount = historyList.length;
          final avgTrip = tripCount > 0 ? (totalSpent / tripCount) : 0.0;
          final totalItems =
              historyList.fold<int>(0, (s, h) => s + h.itemCount);
          final avgItems = tripCount > 0 ? (totalItems / tripCount) : 0.0;

          final monthlyData = _computeMonthlyBreakdown(historyList);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(historyProvider);
              ref.invalidate(frequentItemsProvider);
            },
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                // Top KPI summary row
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Total Spent',
                          value: FormatUtils.formatCurrencyCompact(totalSpent),
                          icon: Icons.account_balance_wallet_rounded,
                          color: AppColors.primaryLight,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Avg. per Trip',
                          value: FormatUtils.formatCurrencyCompact(avgTrip),
                          icon: Icons.receipt_long_rounded,
                          color: AppColors.secondary,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                FadeSlideTransition(
                  delay: const Duration(milliseconds: 100),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Trips Completed',
                          value: '$tripCount',
                          icon: Icons.shopping_bag_rounded,
                          color: AppColors.success,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Avg. Items / Trip',
                          value: avgItems.toStringAsFixed(1),
                          icon: Icons.checklist_rounded,
                          color: AppColors.info,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Monthly Spending Trend Bar Chart
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 160),
                  child: _buildMonthlyBarChart(monthlyData, isDark),
                ),
                const SizedBox(height: 20),

                // Top Frequently Bought Items
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 220),
                  child: _buildFrequentItemsSection(frequentItemsAsync, isDark),
                ),
                const SizedBox(height: 20),

                // Category spending overview
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 280),
                  child: _buildCategoryOverviewSection(categoriesAsync, isDark),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBarChart(Map<String, double> monthlyData, bool isDark) {
    final maxAmount = monthlyData.values.fold<double>(
      1.0,
      (max, val) => val > max ? val : max,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Spending Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              Icon(
                Icons.bar_chart_rounded,
                size: 20,
                color: isDark ? AppColors.primaryNeon : AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Local spend overview across past months',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Bar chart row
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: monthlyData.entries.map((entry) {
                final ratio = (entry.value / maxAmount).clamp(0.06, 1.0);
                final hasSpend = entry.value > 0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (hasSpend)
                          Text(
                            FormatUtils.formatCurrencyCompact(entry.value),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.primaryNeon
                                  : AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeOutCubic,
                          height: 100 * ratio,
                          decoration: BoxDecoration(
                            gradient: hasSpend
                                ? (isDark
                                    ? AppColors.emeraldNeonGradient
                                    : AppColors.primaryGradient)
                                : null,
                            color: hasSpend
                                ? null
                                : (isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: hasSpend
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequentItemsSection(
    AsyncValue<List<dynamic>> frequentItemsAsync,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Frequently Purchased Items',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Smart habits based on past shopping trips',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          frequentItemsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No item frequencies recorded yet. They will appear as you shop!',
                    style: TextStyle(fontSize: 12),
                  ),
                );
              }

              return Column(
                children: items.take(5).toList().asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final item = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF151E2E)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: rank == 1
                                  ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                                  : (isDark
                                      ? AppColors.primaryNeon.withValues(alpha: 0.15)
                                      : AppColors.primary.withValues(alpha: 0.12)),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$rank',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: rank == 1
                                      ? const Color(0xFFF59E0B)
                                      : (isDark
                                          ? AppColors.primaryNeon
                                          : AppColors.primary),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'Default: ${FormatUtils.formatQuantity(item.defaultQuantity as double)} ${item.defaultUnit}'
                                  '${(item.defaultPrice as double) > 0 ? " • ${FormatUtils.formatCurrency(item.defaultPrice as double)}" : ""}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.usageCount}x',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.primaryNeon
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryOverviewSection(
    AsyncValue<List<dynamic>> categoriesAsync,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Smart Aisle Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Items are automatically grouped to minimize in-store backtracking',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          categoriesAsync.when(
            data: (categories) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (cat.icon != null) ...[
                        Text(cat.icon as String,
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        cat.name as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Map<String, double> _computeMonthlyBreakdown(
    List<ShoppingHistoryModel> history,
  ) {
    final Map<String, double> result = {};
    final now = DateTime.now();

    for (int i = 4; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthName = _monthAbbr(date.month);
      result[monthName] = 0.0;
    }

    for (final h in history) {
      final monthName = _monthAbbr(h.completedAt.month);
      if (result.containsKey(monthName)) {
        result[monthName] = result[monthName]! + h.totalAmount;
      }
    }

    return result;
  }

  String _monthAbbr(int month) {
    const abbrs = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return abbrs[month - 1];
  }
}
