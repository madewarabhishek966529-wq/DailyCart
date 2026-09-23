import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/core/utils/format_utils.dart';
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
          'Spending & Analytics',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: historyAsync.when(
        data: (historyList) {
          if (historyList.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.bar_chart_rounded,
              message: 'No shopping data yet.\nComplete your shopping trips to see spending analytics, monthly trends, and charts.',
            );
          }

          final totalSpent = historyList.fold<double>(
            0.0,
            (sum, h) => sum + h.totalAmount,
          );
          final tripCount = historyList.length;
          final avgTrip = tripCount > 0 ? (totalSpent / tripCount) : 0.0;

          // Compute monthly breakdown for past 6 months
          final monthlyData = _computeMonthlyBreakdown(historyList);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(historyProvider);
              ref.invalidate(frequentItemsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Top KPI summary row
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Total Spent',
                        value: FormatUtils.formatCurrencyCompact(totalSpent),
                        icon: Icons.account_balance_wallet_outlined,
                        color: AppColors.primary,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Avg. per Trip',
                        value: FormatUtils.formatCurrencyCompact(avgTrip),
                        icon: Icons.receipt_long_outlined,
                        color: AppColors.secondary,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Trips Completed',
                        value: '$tripCount trips',
                        icon: Icons.shopping_bag_outlined,
                        color: AppColors.success,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Avg. Items / Trip',
                        value: tripCount > 0
                            ? '${(historyList.fold<int>(0, (s, h) => s + h.itemCount) / tripCount).toStringAsFixed(1)} items'
                            : '0',
                        icon: Icons.checklist_rtl_rounded,
                        color: AppColors.info,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Monthly Spending Trend Bar Chart
                _buildMonthlyBarChart(monthlyData, isDark),
                const SizedBox(height: 24),

                // Top Frequently Bought Items
                _buildFrequentItemsSection(frequentItemsAsync, isDark),
                const SizedBox(height: 24),

                // Category spending overview
                _buildCategoryOverviewSection(categoriesAsync, isDark),
                const SizedBox(height: 32),
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              title,
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
    );
  }

  Widget _buildMonthlyBarChart(Map<String, double> monthlyData, bool isDark) {
    final maxAmount = monthlyData.values.fold<double>(
      1.0,
      (max, val) => val > max ? val : max,
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Spending Trend',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
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
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: monthlyData.entries.map((entry) {
                  final ratio = (entry.value / maxAmount).clamp(0.05, 1.0);
                  final hasSpend = entry.value > 0;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (hasSpend)
                            Text(
                              FormatUtils.formatCurrencyCompact(entry.value),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            height: 100 * ratio,
                            decoration: BoxDecoration(
                              color: hasSpend
                                  ? AppColors.primary
                                  : (isDark ? Colors.white10 : Colors.black12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildFrequentItemsSection(
    AsyncValue<List<dynamic>> frequentItemsAsync,
    bool isDark,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Most Frequently Purchased',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Locally learned habits based on your shopping trips',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
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
                  children: items.take(5).map((item) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primary.withAlpha(20),
                        child: Text(
                          '${item.usageCount}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      title: Text(
                        item.name as String,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Default: ${FormatUtils.formatQuantity(item.defaultQuantity as double)} ${item.defaultUnit}'
                        '${(item.defaultPrice as double) > 0 ? " • ${FormatUtils.formatCurrency(item.defaultPrice as double)}" : ""}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      trailing: Text(
                        'Used ${item.usageCount}x',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
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
      ),
    );
  }

  Widget _buildCategoryOverviewSection(
    AsyncValue<List<dynamic>> categoriesAsync,
    bool isDark,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Organized Categories',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Items are automatically sorted by aisle and category',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              data: (categories) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  return Chip(
                    avatar: cat.icon != null ? Text(cat.icon as String) : null,
                    label: Text(cat.name as String),
                  );
                }).toList(),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _computeMonthlyBreakdown(
    List<ShoppingHistoryModel> history,
  ) {
    final Map<String, double> result = {};
    final now = DateTime.now();

    // Past 5 months + current month
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
