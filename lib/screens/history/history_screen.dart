import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/core/utils/app_date_utils.dart';
import 'package:dailycart/core/utils/format_utils.dart';
import 'package:dailycart/models/shopping_history_model.dart';
import 'package:dailycart/models/shopping_list_model.dart';
import 'package:dailycart/providers/history_provider.dart';
import 'package:dailycart/providers/shopping_list_provider.dart';
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
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: historyAsync.when(
        data: (historyList) {
          if (historyList.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.history_rounded,
              message: 'No completed shopping trips yet.\nFinish a shopping list to view your purchase history and repeat trips.',
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
              padding: const EdgeInsets.all(16),
              children: [
                // Top Spend Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1B3820), const Color(0xFF122315)]
                          : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Total Trips', '$tripCount', isDark),
                      Container(
                        height: 40,
                        width: 1,
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                      _buildStatColumn(
                        'Total Spent',
                        FormatUtils.formatCurrencyCompact(totalSpent),
                        isDark,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                      _buildStatColumn(
                        'Average Trip',
                        FormatUtils.formatCurrencyCompact(avgTrip),
                        isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Past Shopping Trips',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),

                ...historyList.map(
                  (history) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildHistoryCard(context, ref, history, isDark),
                  ),
                ),
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
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.success.withAlpha(25),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history.listName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
                  icon: const Icon(Icons.delete_outline, size: 20),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Buy Again Button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                onPressed: () => _handleBuyAgain(context, ref, history),
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: const Text(
                  'Buy Again',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBuyAgain(
    BuildContext context,
    WidgetRef ref,
    ShoppingHistoryModel history,
  ) async {
    final allLists = ref.read(shoppingListsProvider).valueOrNull ?? [];
    // Try to find the source list by name
    final matching = allLists.where((l) => l.name == history.listName).toList();
    final sourceId = matching.isNotEmpty ? matching.first.id : null;

    int newListId;
    if (sourceId != null) {
      newListId = await ref
          .read(shoppingListsProvider.notifier)
          .buyAgain(sourceId, '${history.listName} (Repeat)');
    } else {
      // Create new list
      final now = DateTime.now();
      newListId = await ref
          .read(shoppingListsProvider.notifier)
          .create(
            ShoppingListModel(
              name: '${history.listName} (Repeat)',
              createdAt: now,
              updatedAt: now,
            ),
          );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created new list from "${history.listName}"'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => context.push('/lists/$newListId/shopping'),
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
          'Remove "${history.listName}" from ${AppDateUtils.relativeDate(history.completedAt)}? This will not affect active shopping lists.',
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
              await ref.read(historyProvider.notifier).delete(history.id!);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
