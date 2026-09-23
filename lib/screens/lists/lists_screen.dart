import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dailycart/core/constants/app_constants.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/core/utils/app_date_utils.dart';
import 'package:dailycart/core/utils/format_utils.dart';
import 'package:dailycart/models/shopping_list_model.dart';
import 'package:dailycart/providers/shopping_list_provider.dart';
import 'package:dailycart/widgets/common/empty_state_widget.dart';

enum ListFilter { all, active, completed, archived }

class ListsScreen extends ConsumerStatefulWidget {
  const ListsScreen({super.key});

  @override
  ConsumerState<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends ConsumerState<ListsScreen> {
  final TextEditingController _searchController = TextEditingController();
  ListFilter _selectedFilter = ListFilter.active;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listsAsync = ref.watch(shoppingListsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Lists',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 28),
            tooltip: 'Create New List',
            onPressed: () => _showCreateEditDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search lists...',
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
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.trim().toLowerCase());
              },
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip('Active', ListFilter.active),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', ListFilter.completed),
                const SizedBox(width: 8),
                _buildFilterChip('Archived', ListFilter.archived),
                const SizedBox(width: 8),
                _buildFilterChip('All', ListFilter.all),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lists view
          Expanded(
            child: listsAsync.when(
              data: (lists) {
                final filtered = lists.where((l) {
                  // Status filter
                  if (_selectedFilter == ListFilter.active &&
                      l.status != ListStatus.active) {
                    return false;
                  }
                  if (_selectedFilter == ListFilter.completed &&
                      l.status != ListStatus.completed) {
                    return false;
                  }
                  if (_selectedFilter == ListFilter.archived &&
                      l.status != ListStatus.archived) {
                    return false;
                  }
                  // Search query filter
                  if (_searchQuery.isNotEmpty &&
                      !l.name.toLowerCase().contains(_searchQuery)) {
                    return false;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.list_alt_rounded,
                    message: _searchQuery.isNotEmpty
                        ? 'No lists matching "$_searchQuery"'
                        : _getEmptyFilterMessage(),
                    action: FilledButton.icon(
                      onPressed: () => _showCreateEditDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Create List'),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(shoppingListsProvider);
                  },
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildListCard(context, item, isDark);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
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
                      Text('Error: $err'),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEditDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New List'),
      ),
    );
  }

  String _getEmptyFilterMessage() {
    switch (_selectedFilter) {
      case ListFilter.active:
        return 'No active shopping lists.\nCreate one to get started!';
      case ListFilter.completed:
        return 'No completed lists yet.\nFinish shopping a list to see it here.';
      case ListFilter.archived:
        return 'No archived lists.';
      case ListFilter.all:
        return 'No shopping lists found.\nCreate your first list!';
    }
  }

  Widget _buildFilterChip(String label, ListFilter filter) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = filter);
        }
      },
    );
  }

  Widget _buildListCard(
    BuildContext context,
    ShoppingListModel list,
    bool isDark,
  ) {
    final progress = list.itemCount > 0
        ? (list.completedCount / list.itemCount).clamp(0.0, 1.0)
        : 0.0;
    final isCompleted = list.status == ListStatus.completed;
    final isArchived = list.status == ListStatus.archived;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
          width: 0.8,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/lists/${list.id}/shopping');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Name + Status Chip + Menu Button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      list.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(list.status, isDark),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    padding: EdgeInsets.zero,
                    onSelected: (action) =>
                        _handleAction(context, action, list),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'open',
                        child: Row(
                          children: [
                            Icon(Icons.shopping_bag_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Open / Shop'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Rename / Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'buy_again',
                        child: Row(
                          children: [
                            Icon(Icons.replay_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Buy Again'),
                          ],
                        ),
                      ),
                      if (list.status == ListStatus.active) ...[
                        const PopupMenuItem(
                          value: 'complete',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline, size: 18),
                              SizedBox(width: 8),
                              Text('Mark Complete'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(Icons.archive_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Archive'),
                            ],
                          ),
                        ),
                      ] else if (isCompleted) ...[
                        const PopupMenuItem(
                          value: 'reopen',
                          child: Row(
                            children: [
                              Icon(Icons.unarchive_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Reopen List'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(Icons.archive_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Archive'),
                            ],
                          ),
                        ),
                      ] else if (isArchived) ...[
                        const PopupMenuItem(
                          value: 'reopen',
                          child: Row(
                            children: [
                              Icon(Icons.unarchive_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Unarchive'),
                            ],
                          ),
                        ),
                      ],
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Progress row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${list.completedCount} / ${list.itemCount} items completed',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? Colors.white12
                      : const Color(0xFFEEEEEE),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress == 1.0 ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Financial stats & relative date row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.hasBudget
                            ? '${FormatUtils.formatCurrency(list.estimatedTotal)} / ${FormatUtils.formatCurrency(list.budget)}'
                            : FormatUtils.formatCurrency(list.estimatedTotal),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: list.isOverBudget
                              ? AppColors.budgetOver
                              : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                        ),
                      ),
                      if (list.hasBudget)
                        Text(
                          list.isOverBudget
                              ? 'Over budget by ${FormatUtils.formatCurrencyCompact(list.estimatedTotal - list.budget)}'
                              : '${FormatUtils.formatCurrencyCompact(list.remainingBudget)} remaining',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: list.isOverBudget
                                ? AppColors.budgetOver
                                : AppColors.budgetSafe,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    AppDateUtils.relativeDate(list.updatedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ListStatus status, bool isDark) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case ListStatus.active:
        bg = AppColors.primary.withAlpha(25);
        fg = isDark ? AppColors.primaryLight : AppColors.primary;
        text = 'Active';
        break;
      case ListStatus.completed:
        bg = AppColors.success.withAlpha(25);
        fg = AppColors.success;
        text = 'Completed';
        break;
      case ListStatus.archived:
        bg = Colors.grey.withAlpha(30);
        fg = Colors.grey;
        text = 'Archived';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  void _handleAction(
    BuildContext context,
    String action,
    ShoppingListModel list,
  ) async {
    switch (action) {
      case 'open':
        context.push('/lists/${list.id}/shopping');
        break;
      case 'edit':
        _showCreateEditDialog(context, existingList: list);
        break;
      case 'duplicate':
        final newId = await ref
            .read(shoppingListsProvider.notifier)
            .duplicate(list.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Duplicated "${list.name}"'),
              action: SnackBarAction(
                label: 'View',
                onPressed: () => context.push('/lists/$newId/shopping'),
              ),
            ),
          );
        }
        break;
      case 'buy_again':
        final newId = await ref
            .read(shoppingListsProvider.notifier)
            .buyAgain(list.id!, '${list.name} (Repeat)');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Created new shopping trip for "${list.name}"'),
              action: SnackBarAction(
                label: 'Start Shopping',
                onPressed: () => context.push('/lists/$newId/shopping'),
              ),
            ),
          );
        }
        break;
      case 'complete':
        await ref.read(shoppingListsProvider.notifier).complete(list.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Marked "${list.name}" as completed')),
          );
        }
        break;
      case 'reopen':
        await ref.read(shoppingListsProvider.notifier).reopen(list.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Reopened "${list.name}"')));
        }
        break;
      case 'archive':
        await ref.read(shoppingListsProvider.notifier).archive(list.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Archived "${list.name}"')));
        }
        break;
      case 'delete':
        _confirmDelete(context, list);
        break;
    }
  }

  void _confirmDelete(BuildContext context, ShoppingListModel list) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Delete List?'),
        content: Text(
          'Are you sure you want to delete "${list.name}" and all its ${list.itemCount} items? This cannot be undone.',
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
                  .read(shoppingListsProvider.notifier)
                  .deleteList(list.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted "${list.name}"')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateEditDialog(
    BuildContext context, {
    ShoppingListModel? existingList,
  }) {
    final isEdit = existingList != null;
    final nameController = TextEditingController(
      text: existingList?.name ?? '',
    );
    final budgetController = TextEditingController(
      text: existingList != null && existingList.budget > 0
          ? existingList.budget.toStringAsFixed(0)
          : '',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(isEdit ? 'Edit List' : 'Create Shopping List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'List Name *',
                hintText: 'e.g. Weekend Barbecue',
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
                hintText: 'e.g. 1500',
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

              if (isEdit) {
                await ref
                    .read(shoppingListsProvider.notifier)
                    .updateList(
                      existingList.copyWith(
                        name: name,
                        budget: budget,
                        updatedAt: now,
                      ),
                    );
              } else {
                final newList = ShoppingListModel(
                  name: name,
                  budget: budget,
                  createdAt: now,
                  updatedAt: now,
                );
                final newId = await ref
                    .read(shoppingListsProvider.notifier)
                    .create(newList);
                if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
                if (context.mounted) {
                  context.push('/lists/$newId/shopping');
                }
                return;
              }

              if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }
}
