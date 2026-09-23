import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/models/category_model.dart';
import 'package:dailycart/providers/category_provider.dart';

class CategoriesSheet extends ConsumerWidget {
  const CategoriesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CategoriesSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grocery Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              FilledButton.icon(
                onPressed: () => _showAddCategoryDialog(context, ref),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Custom'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                return ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withAlpha(20),
                        child: Text(
                          cat.icon ?? '🏷️',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      title: Text(
                        cat.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        cat.isDefault ? 'Default Category' : 'Custom Category',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      trailing: cat.isDefault
                          ? const Icon(
                              Icons.lock_outline,
                              size: 18,
                              color: Colors.grey,
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                                size: 20,
                              ),
                              onPressed: () =>
                                  _confirmDeleteCategory(context, ref, cat),
                            ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final iconController = TextEditingController(text: '🛒');

    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('New Custom Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Category Name *',
                hintText: 'e.g. Pet Supplies, Bakery Treats',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: iconController,
              decoration: const InputDecoration(
                labelText: 'Emoji Icon',
                hintText: 'e.g. 🐶, 🍰, 🍷',
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

              final cat = CategoryModel(
                name: name,
                icon: iconController.text.trim().isEmpty
                    ? '🏷️'
                    : iconController.text.trim(),
                isDefault: false,
                createdAt: DateTime.now(),
              );

              await ref.read(categoriesProvider.notifier).add(cat);
              if (dCtx.mounted) Navigator.of(dCtx).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(
    BuildContext context,
    WidgetRef ref,
    CategoryModel cat,
  ) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text('Are you sure you want to delete "${cat.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(dCtx).pop();
              await ref.read(categoriesProvider.notifier).delete(cat.id!);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
