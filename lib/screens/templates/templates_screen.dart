import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dailycart/core/constants/app_constants.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/core/utils/format_utils.dart';
import 'package:dailycart/models/template_item_model.dart';
import 'package:dailycart/models/template_model.dart';
import 'package:dailycart/providers/shopping_list_provider.dart';
import 'package:dailycart/providers/template_provider.dart';
import 'package:dailycart/widgets/common/empty_state_widget.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shopping Templates',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 28),
            tooltip: 'New Template',
            onPressed: () => _showCreateTemplateDialog(context, ref),
          ),
        ],
      ),
      body: templatesAsync.when(
        data: (templates) {
          if (templates.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.copy_rounded,
              message: 'No templates yet.\nCreate pre-filled lists for quick repeat shopping!',
              action: FilledButton.icon(
                onPressed: () => _showCreateTemplateDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create Template'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(templatesProvider),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.all(16),
              itemCount: templates.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final template = templates[index];
                return _TemplateCard(template: template, isDark: isDark);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTemplateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Template'),
      ),
    );
  }

  void _showCreateTemplateDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Create Shopping Template'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Template Name *',
            hintText: 'e.g. Weekend Barbecue, Office Snacks',
          ),
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

              final now = DateTime.now();
              await ref
                  .read(templatesProvider.notifier)
                  .createTemplate(
                    TemplateModel(name: name, createdAt: now, updatedAt: now),
                  );

              if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends ConsumerStatefulWidget {
  const _TemplateCard({required this.template, required this.isDark});

  final TemplateModel template;
  final bool isDark;

  @override
  ConsumerState<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends ConsumerState<_TemplateCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final template = widget.template;
    final isDark = widget.isDark;
    final itemsAsync = ref.watch(templateItemsProvider(template.id!));

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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      itemsAsync.when(
                        data: (items) => Text(
                          '${items.length} pre-configured items',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                        loading: () => const Text('Loading items...'),
                        error: (_, _) => const Text('Items loaded'),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (action) {
                    if (action == 'delete') {
                      _confirmDelete(context);
                    }
                  },
                  itemBuilder: (context) => [
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
                            'Delete Template',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Action Buttons: "Use Template" + "View / Edit Items"
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _useTemplate(context),
                    icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                    label: const Text('Use Template'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                  ),
                  label: Text(_expanded ? 'Hide' : 'Items'),
                ),
              ],
            ),

            // Expanded Items List
            if (_expanded) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Template Items',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddItemDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Item'),
                  ),
                ],
              ),
              itemsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No items in this template yet. Tap "+ Add Item" above!',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: items.map((item) {
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.circle,
                          size: 8,
                          color: AppColors.primary,
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          '${FormatUtils.formatQuantity(item.quantity)} ${item.unit}'
                          '${item.defaultPrice > 0 ? " • ${FormatUtils.formatCurrency(item.defaultPrice)}" : ""}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: () async {
                            await ref
                                .read(templatesProvider.notifier)
                                .deleteItem(item.id!);
                            ref.invalidate(
                              templateItemsProvider(widget.template.id!),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error: $err'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _useTemplate(BuildContext context) {
    final now = DateTime.now();
    final defaultName =
        '${widget.template.name} (${FormatUtils.formatDate(now)})';
    final nameController = TextEditingController(text: defaultName);

    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Create List from Template'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'New List Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final templateRepo = ref.read(templateRepositoryProvider);
              final newListId = await templateRepo.createListFromTemplate(
                widget.template.id!,
                name,
              );

              ref.invalidate(shoppingListsProvider);

              if (dCtx.mounted) Navigator.of(dCtx).pop();
              if (context.mounted) {
                context.push('/lists/$newListId/shopping');
              }
            },
            child: const Text('Create List'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final priceController = TextEditingController();
    String selectedUnit = 'piece';

    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Template Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Item Name *'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Qty'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedUnit,
                      items: AppConstants.units.map((u) {
                        return DropdownMenuItem(value: u, child: Text(u));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedUnit = val);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Default Price (Optional)',
                  prefixText: '${AppConstants.currency} ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final qty = double.tryParse(qtyController.text.trim()) ?? 1.0;
                final price =
                    double.tryParse(priceController.text.trim()) ?? 0.0;

                final item = TemplateItemModel(
                  templateId: widget.template.id!,
                  name: name,
                  quantity: qty,
                  unit: selectedUnit,
                  defaultPrice: price,
                );

                await ref.read(templatesProvider.notifier).addItem(item);
                ref.invalidate(templateItemsProvider(widget.template.id!));
                ref.invalidate(templatesProvider);

                if (dCtx.mounted) Navigator.of(dCtx).pop();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Delete Template?'),
        content: Text(
          'Are you sure you want to delete "${widget.template.name}"?',
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
                  .read(templatesProvider.notifier)
                  .deleteTemplate(widget.template.id!);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
