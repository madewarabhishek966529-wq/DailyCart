import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dailycart/core/services/backup_service.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/providers/category_provider.dart';
import 'package:dailycart/providers/frequent_item_provider.dart';
import 'package:dailycart/providers/history_provider.dart';
import 'package:dailycart/providers/shopping_list_provider.dart';
import 'package:dailycart/providers/template_provider.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  int? _selectedListIdForCsv;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final listsAsync = ref.watch(shoppingListsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Backup & Export',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withAlpha(40)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'All DailyCart data is stored offline on your device in SQLite. '
                    'Use JSON backups to migrate devices or keep a personal offline copy.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Complete JSON Backup Card
          _buildCard(
            isDark: isDark,
            title: 'Complete Database Backup',
            subtitle: 'Exports all lists, items, categories, templates, history, and prices into a single JSON format.',
            icon: Icons.data_object_rounded,
            color: AppColors.primary,
            actions: [
              FilledButton.icon(
                onPressed: _isLoading ? null : _exportJson,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Export JSON Backup'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _restoreJson,
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: const Text('Restore from Backup'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // CSV List Export Card
          _buildCard(
            isDark: isDark,
            title: 'Export Shopping List as CSV',
            subtitle: 'Export an individual shopping list to spreadsheet format (compatible with Excel, Numbers, and Google Sheets).',
            icon: Icons.table_chart_outlined,
            color: AppColors.secondary,
            actions: [
              listsAsync.when(
                data: (lists) {
                  if (lists.isEmpty) {
                    return const Text('No shopping lists available to export.');
                  }

                  final selectedId = _selectedListIdForCsv ?? lists.first.id!;

                  return Column(
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: selectedId,
                        decoration: const InputDecoration(
                          labelText: 'Select List to Export',
                        ),
                        items: lists.map((l) {
                          return DropdownMenuItem(
                            value: l.id!,
                            child: Text(
                              '${l.name} (${l.itemCount} items)',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (id) {
                          if (id != null) {
                            setState(() => _selectedListIdForCsv = id);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => _exportCsv(selectedId),
                          icon: const Icon(
                            Icons.file_download_outlined,
                            size: 18,
                          ),
                          label: const Text('Generate CSV Data'),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error: $err'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Widget> actions,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...actions,
          ],
        ),
      ),
    );
  }

  Future<void> _exportJson() async {
    setState(() => _isLoading = true);
    try {
      final jsonStr = await BackupService.instance.exportFullJson();
      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (dCtx) => AlertDialog(
          title: const Text('Exported Backup JSON'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: SingleChildScrollView(
              child: SelectableText(
                jsonStr,
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(),
              child: const Text('Close'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy to Clipboard'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonStr));
                Navigator.of(dCtx).pop();
                ScaffoldMessenger.of(dCtx).showSnackBar(
                  const SnackBar(
                    content: Text('Backup JSON copied to clipboard!'),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to export backup: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreJson() async {
    final textController = TextEditingController();

    if (!mounted) return;
    final inputJson = await showDialog<String>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Paste Backup JSON'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ Restoring will replace all current lists and items with the backup data.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Paste valid DailyCart JSON content here...',
                contentPadding: EdgeInsets.all(12),
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
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dCtx).pop(textController.text.trim()),
            child: const Text('Restore Data'),
          ),
        ],
      ),
    );

    if (inputJson == null || inputJson.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await BackupService.instance.restoreFromJson(inputJson);
      // Invalidate all providers so UI updates immediately
      ref.invalidate(shoppingListsProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(frequentItemsProvider);
      ref.invalidate(historyProvider);
      ref.invalidate(templatesProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup restored successfully! All data refreshed.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restore failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportCsv(int listId) async {
    setState(() => _isLoading = true);
    try {
      final csvStr = await BackupService.instance.exportListCsv(listId);
      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (dCtx) => AlertDialog(
          title: const Text('Exported CSV Data'),
          content: SizedBox(
            width: double.maxFinite,
            height: 250,
            child: SingleChildScrollView(
              child: SelectableText(
                csvStr,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(),
              child: const Text('Close'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy CSV'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: csvStr));
                Navigator.of(dCtx).pop();
                ScaffoldMessenger.of(dCtx).showSnackBar(
                  const SnackBar(
                    content: Text('CSV data copied to clipboard!'),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to export CSV: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
