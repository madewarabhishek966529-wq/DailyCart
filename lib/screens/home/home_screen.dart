import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dailycart/core/constants/app_constants.dart';
import 'package:dailycart/core/constants/app_routes.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/core/utils/format_utils.dart';
import 'package:dailycart/core/animations/app_animations.dart';
import 'package:dailycart/models/grocery_item_model.dart';
import 'package:dailycart/models/shopping_list_model.dart';
import 'package:dailycart/providers/frequent_item_provider.dart';
import 'package:dailycart/providers/grocery_item_provider.dart';
import 'package:dailycart/providers/history_provider.dart';
import 'package:dailycart/providers/shopping_list_provider.dart';
import 'package:dailycart/widgets/common/app_logo_widget.dart';
import 'package:dailycart/widgets/common/bouncy_tap.dart';
import 'package:dailycart/widgets/shopping/progress_bar_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(shoppingListsProvider);
    final frequentItemsAsync = ref.watch(frequentItemsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayFormatted = DateFormat('EEE, d MMM').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const AppLogoWidget(size: 40, borderRadius: 12, showShadow: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          todayFormatted,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "What's in your cart?",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: BouncyTap(
              onTap: () => _showCreateListDialog(context, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'New List',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: listsAsync.when(
        data: (lists) {
          final activeLists = lists
              .where((l) => l.status == ListStatus.active)
              .toList();
          final currentActiveList =
              activeLists.isNotEmpty ? activeLists.first : null;
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                // 1. Current Active Shopping List Card (Hero Showcase)
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 50),
                  child: _buildActiveListSection(
                    context,
                    ref,
                    currentActiveList,
                    isDark,
                  ),
                ),
                const SizedBox(height: 22),

                // 2. Quick Add Row
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 120),
                  child: _buildQuickAddSection(
                    context,
                    ref,
                    currentActiveList,
                    frequentItemsAsync,
                    isDark,
                  ),
                ),
                const SizedBox(height: 22),

                // 3. Monthly Spend & Insights Deck
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 190),
                  child: _buildMonthlyStatsSection(context, ref, isDark),
                ),
                const SizedBox(height: 22),

                // 4. Recent Lists Section
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 260),
                  child: _buildRecentListsSection(context, recentLists, isDark),
                ),
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
                  Icons.error_outline_rounded,
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
      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primaryLight.withValues(alpha: 0.08),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.primaryLight,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'No Active Shopping List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Create a grocery list to organize your cart, track budget in real-time, and check off items.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              BouncyTap(
                onTap: () => _showCreateListDialog(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 18, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Create Shopping List',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
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

    final progress = activeList.itemCount > 0
        ? (activeList.completedCount / activeList.itemCount).clamp(0.0, 1.0)
        : 0.0;
    final percentInt = (progress * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF0F231D), Color(0xFF101C2B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFECFDF5), Color(0xFFF0FDF4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.primaryLight.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge & Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.primaryNeon.withValues(alpha: 0.18)
                        : AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primaryNeon
                              : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ACTIVE SHOPPING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: isDark
                              ? AppColors.primaryNeon
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$percentInt% done',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // List Title
            Text(
              activeList.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),

            // Progress Bar
            ProgressBarWidget(
              value: progress,
              height: 10,
              borderRadius: 6,
            ),
            const SizedBox(height: 14),

            // Stats Row: Completed count & Estimated total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items in Cart',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${activeList.completedCount} / ${activeList.itemCount} completed',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      activeList.hasBudget ? 'Estimated / Budget' : 'Total Est.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          FormatUtils.formatCurrency(activeList.estimatedTotal),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: activeList.isOverBudget
                                ? AppColors.budgetOver
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                          ),
                        ),
                        if (activeList.hasBudget) ...[
                          Text(
                            ' / ${FormatUtils.formatCurrency(activeList.budget)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // [ Continue Shopping ] Floating Button
            BouncyTap(
              onTap: () {
                context.push('/lists/${activeList.id}/shopping');
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_checkout_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Continue Shopping',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Colors.white,
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

  Widget _buildQuickAddSection(
    BuildContext context,
    WidgetRef ref,
    ShoppingListModel? activeList,
    AsyncValue<List<dynamic>> frequentItemsAsync,
    bool isDark,
  ) {
    const defaultQuickAdd = [
      '🥛 Milk',
      '🥚 Eggs',
      '🍞 Bread',
      '🍚 Rice',
      '🍌 Bananas',
      '🍅 Tomatoes',
      '🥔 Potatoes',
      '🧀 Cheese',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Quick Add',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            if (activeList != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'to ${activeList.name}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        frequentItemsAsync.when(
          data: (items) {
            final names = items.isNotEmpty
                ? items.map((e) => e.name as String).take(8).toList()
                : defaultQuickAdd;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: names.map((name) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: BouncyTap(
                      scaleFactor: 0.92,
                      onTap: () =>
                          _handleQuickAddItem(context, ref, activeList, name),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              size: 16,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  child: BouncyTap(
                    onTap: () =>
                        _handleQuickAddItem(context, ref, activeList, name),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
    // Strip leading emoji if present for clean grocery name
    final cleanedName = itemName.replaceFirst(RegExp(r'^[^\w\s]+\s*'), '').trim();

    if (activeList == null) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please create or select an active list first.'),
          action: SnackBarAction(
            label: 'Create',
            textColor: AppColors.primaryNeon,
            onPressed: () => _showCreateListDialog(context, ref),
          ),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();

    final item = GroceryItemModel(
      listId: activeList.id!,
      name: cleanedName,
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
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: AppColors.primaryNeon,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Added "$cleanedName" to ${activeList.name}'),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildMonthlyStatsSection(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    final now = DateTime.now();
    final monthlyTotalAsync = ref.watch(monthlySpendProvider(now));

    return Container(
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
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${FormatUtils.formatMonthYear(now)} Spend',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    loading: () => const Text('Loading...'),
                    error: (_, _) => const Text('₹0.00'),
                  ),
                ],
              ),
            ),
            BouncyTap(
              onTap: () => context.go(AppRoutes.analytics),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Insights',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            BouncyTap(
              onTap: () => context.go(AppRoutes.lists),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...recentLists.map((list) {
          final isCompleted = list.status == ListStatus.completed;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: BouncyTap(
              onTap: () {
                context.push('/lists/${list.id}/shopping');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.shopping_bag_outlined,
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.primaryLight,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            list.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${list.itemCount} items • ${FormatUtils.formatCurrency(list.estimatedTotal)}',
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
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
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
            const SizedBox(height: 14),
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
