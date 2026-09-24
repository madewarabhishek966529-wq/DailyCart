import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/core/utils/format_utils.dart';
import 'package:dailycart/core/animations/app_animations.dart';
import 'package:dailycart/models/shopping_history_model.dart';
import 'package:dailycart/models/shopping_list_model.dart';
import 'package:dailycart/providers/history_provider.dart';
import 'package:dailycart/providers/shopping_list_provider.dart';
import 'package:dailycart/widgets/common/bouncy_tap.dart';
import 'package:dailycart/widgets/common/empty_state_widget.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shopping History',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: historyAsync.when(
        data: (historyList) {
          if (historyList.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.history_rounded,
              title: 'No Completed Shopping Trips',
              message:
                  'Finish a shopping list to save your purchase history, track lifetime expenditures, and repeat trips anytime.',
            );
          }

          final totalSpent = historyList.fold<double>(
            0.0,
            (sum, h) => sum + h.totalAmount,
          );
          final tripCount = historyList.length;
          final avgTrip = tripCount > 0 ? (totalSpent / tripCount) : 0.0;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(historyProvider),
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                // Top Spend Summary Showcase Card
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 40),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? const LinearGradient(
                              colors: [Color(0xFF0F261E), Color(0xFF101B2E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFFECFDF5), Color(0xFFF0FDF4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark
                            ? AppColors.primaryLight.withValues(alpha: 0.3)
                            : AppColors.primary.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('Total Trips', '$tripCount', isDark),
                        Container(
                          height: 36,
                          width: 1,
                          color: isDark
                              ? const Color(0x2EFFFFFF)
                              : const Color(0x26000000),
                        ),
                        _buildStatColumn(
                          'Total Spent',
                          FormatUtils.formatCurrencyCompact(totalSpent),
                          isDark,
                        ),
                        Container(
                          height: 36,
                          width: 1,
                          color: isDark
                              ? const Color(0x2EFFFFFF)
                              : const Color(0x26000000),
                        ),
                        _buildStatColumn(
                          'Average Trip',
                          FormatUtils.formatCurrencyCompact(avgTrip),
                          isDark,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                const Text(
                  'Past Shopping Trips',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),

                ...historyList.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final history = entry.value;

                  return FadeSlideTransition(
                    delay: Duration(milliseconds: 50 * idx + 100),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildHistoryCard(context, ref, history, isDark),
                    ),
                  );
                }),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading history: $err')),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: isDark ? Colors.white : AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    WidgetRef ref,
    ShoppingHistoryModel history,
    bool isDark,
  ) {
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
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.listName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      FormatUtils.formatDateTime(history.completedAt),
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
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: isDark ? Colors.white38 : Colors.black38,
                onPressed: () => _confirmDelete(context, ref, history),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${history.itemCount} items purchased',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                FormatUtils.formatCurrency(history.totalAmount),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Buy Again Button
          BouncyTap(
            onTap: () => _handleBuyAgain(context, ref, history),
            child: Container(
              width: double.infinity,
              height: 42,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.replay_rounded,
                    size: 16,
                    color: isDark
                        ? AppColors.primaryNeon
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Buy Again',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark
                          ? AppColors.primaryNeon
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBuyAgain(
    BuildContext context,
    WidgetRef ref,
    ShoppingHistoryModel history,
  ) async {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final newList = ShoppingListModel(
      name: '${history.listName} (Repeat)',
      budget: history.totalAmount,
      createdAt: now,
      updatedAt: now,
    );
    final newId =
        await ref.read(shoppingListsProvider.notifier).create(newList);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created new list from "${history.listName}"'),
          action: SnackBarAction(
            label: 'Open',
            textColor: AppColors.primaryNeon,
            onPressed: () => context.push('/lists/$newId/shopping'),
          ),
        ),
      );
    }
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ShoppingHistoryModel history,
  ) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Delete Trip History?'),
        content: Text(
          'Remove record for "${history.listName}" on ${FormatUtils.formatDate(history.completedAt)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(dCtx).pop();
              await ref
                  .read(historyProvider.notifier)
                  .delete(history.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Record deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
