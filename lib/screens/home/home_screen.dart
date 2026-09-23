import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dailycart/core/constants/app_constants.dart';
import 'package:dailycart/core/constants/app_routes.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/core/utils/format_utils.dart';
import 'package:dailycart/models/grocery_item_model.dart';
import 'package:dailycart/models/shopping_list_model.dart';
import 'package:dailycart/providers/frequent_item_provider.dart';
import 'package:dailycart/providers/grocery_item_provider.dart';
import 'package:dailycart/providers/history_provider.dart';
import 'package:dailycart/providers/shopping_list_provider.dart';
import 'package:dailycart/widgets/common/app_logo_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning 👋';
    } else if (hour < 17) {
      return 'Good afternoon ☀️';
    } else {
      return 'Good evening 🌙';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(shoppingListsProvider);
    final frequentItemsAsync = ref.watch(frequentItemsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const AppLogoWidget(size: 38, borderRadius: 10, showShadow: false),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    "What's on your cart?",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
            tooltip: 'Create New List',
            onPressed: () => _showCreateListDialog(context, ref),
          ),
        ],
      ),
      body: listsAsync.when(
        data: (lists) {
          final activeLists = lists
              .where((l) => l.status == ListStatus.active)
              .toList();
          final currentActiveList = activeLists.isNotEmpty
              ? activeLists.first
              : null;
          final recentLists = lists.take(4).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(shoppingListsProvider);
              ref.invalidate(frequentItemsProvider);
            },
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // 1. Current Active Shopping List Card
                _buildActiveListSection(
                  context,
                  ref,
                  currentActiveList,
                  isDark,
                ),
                const SizedBox(height: 24),

                // 2. Quick Add Row
                _buildQuickAddSection(
                  context,
                  ref,
                  currentActiveList,
                  frequentItemsAsync,
                  isDark,
                ),
                const SizedBox(height: 24),

                // 3. Recent Lists Section
                _buildRecentListsSection(context, recentLists, isDark),
                const SizedBox(height: 24),

                // 4. Monthly Summary / Secondary Statistics
                _buildMonthlyStatsSection(context, ref, isDark),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 12),
                Text('Could not load shopping lists: $err'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(shoppingListsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveListSection(
    BuildContext context,
    WidgetRef ref,
    ShoppingListModel? activeList,
    bool isDark,
  ) {
    if (activeList == null) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Active Shopping List',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Create a grocery list to organize items and track your shopping budget.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => _showCreateListDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create Shopping List'),
              ),
            ],
          ),
        ),
      );
    }

    final progress = activeList.itemCount > 0
        ? (activeList.completedCount / activeList.itemCount).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    activeList.name,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.primaryLight
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Progress text: 8 / 15 completed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${activeList.completedCount} / ${activeList.itemCount} completed',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: isDark
                    ? Colors.white12
                    : const Color(0xFFEEEEEE),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress == 1.0 ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Pricing & Budget: ₹1,240 / ₹2,000
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Total',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activeList.hasBudget
                          ? '${FormatUtils.formatCurrency(activeList.estimatedTotal)} / ${FormatUtils.formatCurrency(activeList.budget)}'
                          : FormatUtils.formatCurrency(
                              activeList.estimatedTotal,
                            ),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: activeList.isOverBudget
                            ? AppColors.budgetOver
                            : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                if (activeList.hasBudget)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (activeList.isOverBudget
                                  ? AppColors.budgetOver
                                  : AppColors.budgetSafe)
                              .withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      activeList.isOverBudget
                          ? 'Over budget'
                          : '${FormatUtils.formatCurrencyCompact(activeList.remainingBudget)} left',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: activeList.isOverBudget
                            ? AppColors.budgetOver
                            : AppColors.budgetSafe,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // [ Continue Shopping ] Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton.icon(
                onPressed: () {
                  context.push('/lists/${activeList.id}/shopping');
                },
                icon: const Icon(
                  Icons.shopping_cart_checkout_rounded,
                  size: 20,
                ),
                label: const Text(
                  'Continue Shopping',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddSection(
    BuildContext context,
    WidgetRef ref,
    ShoppingListModel? activeList,
    AsyncValue<List<dynamic>> frequentItemsAsync,
    bool isDark,
  ) {
    const defaultQuickAdd = [
      'Milk',
      'Eggs',
      'Bread',
      'Rice',
      'Bananas',
      'Tomatoes',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Quick Add',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            if (activeList != null)
              Text(
                'to ${activeList.name}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        frequentItemsAsync.when(
          data: (items) {
            final names = items.isNotEmpty
                ? items.map((e) => e.name as String).take(8).toList()
                : defaultQuickAdd;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: names.map((name) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: Text(name),
                      backgroundColor: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      onPressed: () =>
                          _handleQuickAddItem(context, ref, activeList, name),
                    ),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const SizedBox(
            height: 36,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, _) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: defaultQuickAdd.map((name) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: Text(name),
                    onPressed: () =>
                        _handleQuickAddItem(context, ref, activeList, name),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleQuickAddItem(
    BuildContext context,
    WidgetRef ref,
    ShoppingListModel? activeList,
    String itemName,
  ) async {
    if (activeList == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please create or select an active list first.'),
          action: SnackBarAction(
            label: 'Create',
            onPressed: () => _showCreateListDialog(context, ref),
          ),
        ),
      );
      return;
    }

    final item = GroceryItemModel(
      listId: activeList.id!,
      name: itemName,
      quantity: 1,
      unit: 'piece',
      unitPrice: 0,
      totalPrice: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(groceryItemsProvider(activeList.id!).notifier).add(item);
    ref.invalidate(shoppingListsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $itemName to "${activeList.name}"'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildRecentListsSection(
    BuildContext context,
    List<ShoppingListModel> recentLists,
    bool isDark,
  ) {
    if (recentLists.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Lists',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.lists),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recentLists.map((list) {
          final isCompleted = list.status == ListStatus.completed;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: CircleAvatar(
                backgroundColor: isCompleted
                    ? AppColors.success.withAlpha(25)
                    : AppColors.primary.withAlpha(25),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.shopping_basket_rounded,
                  color: isCompleted ? AppColors.success : AppColors.primary,
                  size: 20,
                ),
              ),
              title: Text(
                list.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${list.itemCount} items • ${FormatUtils.formatCurrency(list.estimatedTotal)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                context.push('/lists/${list.id}/shopping');
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMonthlyStatsSection(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    final now = DateTime.now();
    final monthlyTotalAsync = ref.watch(monthlySpendProvider(now));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: AppColors.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${FormatUtils.formatMonthYear(now)} Spend',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  monthlyTotalAsync.when(
                    data: (total) => Text(
                      FormatUtils.formatCurrency(total),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    loading: () => const Text('Loading...'),
                    error: (_, _) => const Text('₹0.00'),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.analytics),
              child: const Text('Analytics'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateListDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Create Shopping List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'List Name *',
                hintText: 'e.g. Weekly Grocery',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: budgetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Budget (Optional)',
                hintText: 'e.g. 2000',
                prefixText: '${AppConstants.currency} ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final budget = double.tryParse(budgetController.text.trim()) ?? 0;
              final now = DateTime.now();

              final newList = ShoppingListModel(
                name: name,
                budget: budget,
                createdAt: now,
                updatedAt: now,
              );

              final newId = await ref
                  .read(shoppingListsProvider.notifier)
                  .create(newList);

              if (dialogCtx.mounted) {
                Navigator.of(dialogCtx).pop();
              }
              if (context.mounted) {
                context.push('/lists/$newId/shopping');
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
