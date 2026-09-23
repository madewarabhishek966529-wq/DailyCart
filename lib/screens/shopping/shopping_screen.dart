import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dailycart/core/constants/app_constants.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/core/utils/format_utils.dart';
import 'package:dailycart/models/grocery_item_model.dart';
import 'package:dailycart/models/shopping_history_model.dart';
import 'package:dailycart/models/shopping_list_model.dart';
import 'package:dailycart/providers/grocery_item_provider.dart';
import 'package:dailycart/providers/history_provider.dart';
import 'package:dailycart/providers/shopping_list_provider.dart';
import 'package:dailycart/widgets/common/empty_state_widget.dart';
import 'package:dailycart/widgets/shopping/add_edit_item_sheet.dart';
import 'package:dailycart/widgets/shopping/item_tile_widget.dart';

enum ItemFilter { all, toBuy, purchased, highPriority }

enum ItemSort {
  custom,
  name,
  category,
  priority,
  priceHigh,
  priceLow,
  recentlyAdded,
}

class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key, required this.listId});

  final int listId;

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  final TextEditingController _searchController = TextEditingController();
  ItemFilter _selectedFilter = ItemFilter.all;
  ItemSort _selectedSort = ItemSort.custom;
  bool _isCategoryView = false;
  String _searchQuery = '';
  bool _purchasedExpanded = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(shoppingListByIdProvider(widget.listId));
    final itemsAsync = ref.watch(groceryItemsProvider(widget.listId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return listAsync.when(
      data: (shoppingList) {
        if (shoppingList == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Shopping list not found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              shoppingList.name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            actions: [
              // Toggle List / Category view
              IconButton(
                icon: Icon(
                  _isCategoryView
                      ? Icons.view_list_rounded
                      : Icons.category_outlined,
                ),
                tooltip: _isCategoryView ? 'List View' : 'Category View',
                onPressed: () {
                  setState(() => _isCategoryView = !_isCategoryView);
                },
              ),
              // Sort menu
              PopupMenuButton<ItemSort>(
                icon: const Icon(Icons.sort_rounded),
                tooltip: 'Sort items',
                onSelected: (sort) {
                  setState(() => _selectedSort = sort);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: ItemSort.custom,
                    child: Text('Custom Order (Drag & Drop)'),
                  ),
                  const PopupMenuItem(
                    value: ItemSort.name,
                    child: Text('Name (A-Z)'),
                  ),
                  const PopupMenuItem(
                    value: ItemSort.category,
                    child: Text('Category'),
                  ),
                  const PopupMenuItem(
                    value: ItemSort.priority,
                    child: Text('High Priority First'),
                  ),
                  const PopupMenuItem(
                    value: ItemSort.priceHigh,
                    child: Text('Price: High to Low'),
                  ),
                  const PopupMenuItem(
                    value: ItemSort.priceLow,
                    child: Text('Price: Low to High'),
                  ),
                  const PopupMenuItem(
                    value: ItemSort.recentlyAdded,
                    child: Text('Recently Added'),
                  ),
                ],
              ),
              // Options menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (action) =>
                    _handleListMenuAction(context, action, shoppingList),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'complete_shopping',
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: AppColors.success,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text('Finish Shopping'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'mark_all_purchased',
                    child: Row(
                      children: [
                        Icon(Icons.done_all_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Mark All as Purchased'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reset_all',
                    child: Row(
                      children: [
                        Icon(Icons.refresh_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Reset All to "To Buy"'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'edit_list',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit Name & Budget'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: itemsAsync.when(
            data: (items) {
              return Column(
                children: [
                  // Budget & Progress Header
                  _buildBudgetAndProgressCard(shoppingList, items, isDark),

                  // Search & Filter row
                  _buildSearchAndFilterBar(isDark),

                  // Items List / Category View
                  Expanded(
                    child: _buildItemsContent(items, shoppingList, isDark),
                  ),

                  // Bottom Summary Bar
                  _buildBottomSummaryBar(shoppingList, items, isDark),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading items: $err')),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () =>
                AddEditItemSheet.show(context, listId: widget.listId),
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) =>
          Scaffold(body: Center(child: Text('Error loading list: $err'))),
    );
  }

  Widget _buildBudgetAndProgressCard(
    ShoppingListModel list,
    List<GroceryItemModel> items,
    bool isDark,
  ) {
    final totalItems = items.length;
    final purchasedItems = items.where((i) => i.isPurchased).length;
    final progress = totalItems > 0
        ? (purchasedItems / totalItems).clamp(0.0, 1.0)
        : 0.0;

    final estimatedTotal = items.fold<double>(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
    final actualTotal = items
        .where((i) => i.isPurchased)
        .fold<double>(
          0.0,
          (sum, item) =>
              sum +
              (item.actualTotalPrice > 0
                  ? item.actualTotalPrice
                  : item.totalPrice),
        );

    final hasBudget = list.hasBudget;
    final isOverBudget = hasBudget && estimatedTotal > list.budget;
    final isNearBudget =
        hasBudget && estimatedTotal >= list.budget * 0.85 && !isOverBudget;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverBudget
              ? AppColors.budgetOver
              : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8)),
          width: isOverBudget ? 1.5 : 0.8,
        ),
      ),
      child: Column(
        children: [
          // Progress numbers: "8 / 15 items"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$purchasedItems / $totalItems completed',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark
                  ? Colors.white12
                  : const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Budget row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated: ${FormatUtils.formatCurrency(estimatedTotal)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (purchasedItems > 0)
                    Text(
                      'Actual so far: ${FormatUtils.formatCurrency(actualTotal)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
              if (hasBudget)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isOverBudget
                                ? AppColors.budgetOver
                                : (isNearBudget
                                      ? AppColors.budgetWarning
                                      : AppColors.budgetSafe))
                            .withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Budget: ${FormatUtils.formatCurrencyCompact(list.budget)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isOverBudget
                              ? AppColors.budgetOver
                              : (isNearBudget
                                    ? AppColors.budgetWarning
                                    : AppColors.budgetSafe),
                        ),
                      ),
                      Text(
                        isOverBudget
                            ? 'Over by ${FormatUtils.formatCurrencyCompact(estimatedTotal - list.budget)}'
                            : '${FormatUtils.formatCurrencyCompact(list.budget - estimatedTotal)} left',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isOverBudget
                              ? AppColors.budgetOver
                              : (isNearBudget
                                    ? AppColors.budgetWarning
                                    : AppColors.budgetSafe),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search input
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search items, categories, notes...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
            ),
            onChanged: (val) {
              setState(() => _searchQuery = val.trim().toLowerCase());
            },
          ),
          const SizedBox(height: 6),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', ItemFilter.all),
                const SizedBox(width: 6),
                _buildFilterChip('To Buy', ItemFilter.toBuy),
                const SizedBox(width: 6),
                _buildFilterChip('Purchased', ItemFilter.purchased),
                const SizedBox(width: 6),
                _buildFilterChip('High Priority', ItemFilter.highPriority),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ItemFilter filter) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      padding: EdgeInsets.zero,
      onSelected: (sel) {
        if (sel) setState(() => _selectedFilter = filter);
      },
    );
  }

  List<GroceryItemModel> _applyFilterAndSort(List<GroceryItemModel> items) {
    final filtered = items.where((item) {
      // Filter tab
      if (_selectedFilter == ItemFilter.toBuy && item.isPurchased) {
        return false;
      }
      if (_selectedFilter == ItemFilter.purchased && !item.isPurchased) {
        return false;
      }
      if (_selectedFilter == ItemFilter.highPriority &&
          item.priority != ItemPriority.high) {
        return false;
      }
      // Search query
      if (_searchQuery.isNotEmpty) {
        final nameMatch = item.name.toLowerCase().contains(_searchQuery);
        final noteMatch =
            item.note != null &&
            item.note!.toLowerCase().contains(_searchQuery);
        final catMatch =
            item.categoryName != null &&
            item.categoryName!.toLowerCase().contains(_searchQuery);
        if (!nameMatch && !noteMatch && !catMatch) return false;
      }
      return true;
    }).toList();

    // Sort
    switch (_selectedSort) {
      case ItemSort.custom:
        filtered.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        break;
      case ItemSort.name:
        filtered.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case ItemSort.category:
        filtered.sort(
          (a, b) => (a.categoryName ?? '').compareTo(b.categoryName ?? ''),
        );
        break;
      case ItemSort.priority:
        final order = {
          ItemPriority.high: 0,
          ItemPriority.normal: 1,
          ItemPriority.low: 2,
        };
        filtered.sort(
          (a, b) => order[a.priority]!.compareTo(order[b.priority]!),
        );
        break;
      case ItemSort.priceHigh:
        filtered.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
        break;
      case ItemSort.priceLow:
        filtered.sort((a, b) => a.totalPrice.compareTo(b.totalPrice));
        break;
      case ItemSort.recentlyAdded:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return filtered;
  }

  Widget _buildItemsContent(
    List<GroceryItemModel> rawItems,
    ShoppingListModel shoppingList,
    bool isDark,
  ) {
    if (rawItems.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.add_shopping_cart_rounded,
        message: 'No items in this list yet.\nTap "+ Add Item" below!',
        action: FilledButton.icon(
          onPressed: () =>
              AddEditItemSheet.show(context, listId: widget.listId),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Grocery Item'),
        ),
      );
    }

    final filtered = _applyFilterAndSort(rawItems);

    if (filtered.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.search_off_rounded,
        message: 'No items match your search or filter.',
      );
    }

    if (_isCategoryView) {
      return _buildCategoryGroupedView(filtered, isDark);
    }

    // Default separated List View: TO BUY vs PURCHASED
    final toBuyItems = filtered.where((i) => !i.isPurchased).toList();
    final purchasedItems = filtered.where((i) => i.isPurchased).toList();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(groceryItemsProvider(widget.listId));
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        children: [
          // TO BUY SECTION
          if (toBuyItems.isNotEmpty || _selectedFilter == ItemFilter.toBuy) ...[
            _buildSectionHeader('TO BUY', toBuyItems.length, AppColors.primary),
            if (_selectedSort == ItemSort.custom)
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: toBuyItems.length,
                // ignore: deprecated_member_use
                onReorder: (oldIndex, newIndex) {
                  final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
                  final item = toBuyItems.removeAt(oldIndex);
                  toBuyItems.insert(target, item);
                  ref
                      .read(groceryItemsProvider(widget.listId).notifier)
                      .reorder(widget.listId, toBuyItems);
                },
                itemBuilder: (context, idx) {
                  final itm = toBuyItems[idx];
                  return Container(
                    key: ValueKey('item_${itm.id}'),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ItemTileWidget(
                      item: itm,
                      showReorderHandle: true,
                      onTogglePurchased: (_) => _toggleItemPurchased(itm),
                      onTap: () => AddEditItemSheet.show(
                        context,
                        listId: widget.listId,
                        existingItem: itm,
                      ),
                      onDelete: () => _deleteItem(itm),
                      onQuantityChanged: (qty) => _updateItemQuantity(itm, qty),
                    ),
                  );
                },
              )
            else
              ...toBuyItems.map(
                (itm) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ItemTileWidget(
                    item: itm,
                    onTogglePurchased: (_) => _toggleItemPurchased(itm),
                    onTap: () => AddEditItemSheet.show(
                      context,
                      listId: widget.listId,
                      existingItem: itm,
                    ),
                    onDelete: () => _deleteItem(itm),
                    onQuantityChanged: (qty) => _updateItemQuantity(itm, qty),
                  ),
                ),
              ),
          ],

          // PURCHASED SECTION
          if (purchasedItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () =>
                  setState(() => _purchasedExpanded = !_purchasedExpanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      _purchasedExpanded
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.keyboard_arrow_right_rounded,
                      color: AppColors.success,
                      size: 22,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'PURCHASED (${purchasedItems.length})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_purchasedExpanded)
              ...purchasedItems.map(
                (itm) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ItemTileWidget(
                    item: itm,
                    onTogglePurchased: (_) => _toggleItemPurchased(itm),
                    onTap: () => AddEditItemSheet.show(
                      context,
                      listId: widget.listId,
                      existingItem: itm,
                    ),
                    onDelete: () => _deleteItem(itm),
                    onQuantityChanged: (qty) => _updateItemQuantity(itm, qty),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        '$title ($count)',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCategoryGroupedView(List<GroceryItemModel> items, bool isDark) {
    final Map<String, List<GroceryItemModel>> grouped = {};
    for (final itm in items) {
      final cat = itm.categoryName ?? 'Other';
      grouped.putIfAbsent(cat, () => []).add(itm);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      children: grouped.entries.map((entry) {
        final categoryName = entry.key;
        final catItems = entry.value;
        final subtotal = catItems.fold<double>(
          0.0,
          (sum, i) => sum + i.totalPrice,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$categoryName (${catItems.length})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    FormatUtils.formatCurrency(subtotal),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ...catItems.map(
              (itm) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ItemTileWidget(
                  item: itm,
                  onTogglePurchased: (_) => _toggleItemPurchased(itm),
                  onTap: () => AddEditItemSheet.show(
                    context,
                    listId: widget.listId,
                    existingItem: itm,
                  ),
                  onDelete: () => _deleteItem(itm),
                  onQuantityChanged: (qty) => _updateItemQuantity(itm, qty),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBottomSummaryBar(
    ShoppingListModel list,
    List<GroceryItemModel> items,
    bool isDark,
  ) {
    final purchasedCount = items.where((i) => i.isPurchased).length;
    final allPurchased = items.isNotEmpty && purchasedCount == items.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$purchasedCount of ${items.length} items checked',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  FormatUtils.formatCurrency(list.estimatedTotal),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: allPurchased
                  ? AppColors.success
                  : AppColors.primary,
            ),
            onPressed: items.isEmpty
                ? null
                : () => _finishShoppingSession(context, list, items),
            icon: const Icon(Icons.check, size: 18),
            label: Text(allPurchased ? 'Finish Trip' : 'Done Shopping'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleItemPurchased(GroceryItemModel item) async {
    await ref
        .read(groceryItemsProvider(widget.listId).notifier)
        .togglePurchased(item);
    ref.invalidate(shoppingListsProvider);
    ref.invalidate(shoppingListByIdProvider(widget.listId));
  }

  Future<void> _updateItemQuantity(GroceryItemModel item, double newQty) async {
    final updated = item.copyWith(
      quantity: newQty,
      totalPrice: newQty * item.unitPrice,
      actualTotalPrice: newQty * item.actualUnitPrice,
      updatedAt: DateTime.now(),
    );
    await ref
        .read(groceryItemsProvider(widget.listId).notifier)
        .updateItem(updated);
    ref.invalidate(shoppingListsProvider);
    ref.invalidate(shoppingListByIdProvider(widget.listId));
  }

  Future<void> _deleteItem(GroceryItemModel item) async {
    await ref
        .read(groceryItemsProvider(widget.listId).notifier)
        .deleteItem(item);
    ref.invalidate(shoppingListsProvider);
    ref.invalidate(shoppingListByIdProvider(widget.listId));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${item.name}"'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              await ref
                  .read(groceryItemsProvider(widget.listId).notifier)
                  .add(item);
              ref.invalidate(shoppingListsProvider);
              ref.invalidate(shoppingListByIdProvider(widget.listId));
            },
          ),
        ),
      );
    }
  }

  void _handleListMenuAction(
    BuildContext context,
    String action,
    ShoppingListModel list,
  ) async {
    final notifier = ref.read(groceryItemsProvider(widget.listId).notifier);
    final items =
        ref.read(groceryItemsProvider(widget.listId)).valueOrNull ?? [];

    switch (action) {
      case 'complete_shopping':
        _finishShoppingSession(context, list, items);
        break;
      case 'mark_all_purchased':
        for (final itm in items) {
          if (!itm.isPurchased) {
            await notifier.togglePurchased(itm);
          }
        }
        ref.invalidate(shoppingListsProvider);
        ref.invalidate(shoppingListByIdProvider(widget.listId));
        break;
      case 'reset_all':
        for (final itm in items) {
          if (itm.isPurchased) {
            await notifier.togglePurchased(itm);
          }
        }
        ref.invalidate(shoppingListsProvider);
        ref.invalidate(shoppingListByIdProvider(widget.listId));
        break;
      case 'edit_list':
        _showEditListDialog(context, list);
        break;
    }
  }

  Future<void> _finishShoppingSession(
    BuildContext context,
    ShoppingListModel list,
    List<GroceryItemModel> items,
  ) async {
    final purchasedItems = items.where((i) => i.isPurchased).toList();
    final actualTotal = purchasedItems.fold<double>(
      0.0,
      (sum, item) =>
          sum +
          (item.actualTotalPrice > 0 ? item.actualTotalPrice : item.totalPrice),
    );
    final costDiff = actualTotal - list.estimatedTotal;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Complete Shopping Session?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${purchasedItems.length} of ${items.length} items purchased.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estimated Cost:'),
                Text(
                  FormatUtils.formatCurrency(list.estimatedTotal),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Actual Spend:'),
                Text(
                  FormatUtils.formatCurrency(actualTotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Difference:'),
                Text(
                  '${costDiff >= 0 ? '+' : ''}${FormatUtils.formatCurrency(costDiff)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: costDiff > 0 ? AppColors.error : AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Keep Shopping'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Complete Trip'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final now = DateTime.now();

      // Record to history repository
      final historyRecord = ShoppingHistoryModel(
        listName: list.name,
        totalAmount: actualTotal > 0 ? actualTotal : list.estimatedTotal,
        itemCount: purchasedItems.isNotEmpty
            ? purchasedItems.length
            : items.length,
        completedAt: now,
      );
      await ref.read(historyProvider.notifier).add(historyRecord);

      // Mark list completed
      await ref.read(shoppingListsProvider.notifier).complete(list.id!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shopping completed and saved to history! 🎉'),
          ),
        );
        context.go('/history');
      }
    }
  }

  void _showEditListDialog(BuildContext context, ShoppingListModel list) {
    final nameController = TextEditingController(text: list.name);
    final budgetController = TextEditingController(
      text: list.budget > 0 ? list.budget.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Edit List Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'List Name *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: budgetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Budget (Optional)',
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
              await ref
                  .read(shoppingListsProvider.notifier)
                  .updateList(
                    list.copyWith(
                      name: name,
                      budget: budget,
                      updatedAt: DateTime.now(),
                    ),
                  );
              ref.invalidate(shoppingListByIdProvider(widget.listId));
              if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
