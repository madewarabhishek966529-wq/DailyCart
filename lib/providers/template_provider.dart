import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dailycart/models/template_model.dart';
import 'package:dailycart/models/template_item_model.dart';
import 'package:dailycart/repositories/template_repository.dart';
import 'package:dailycart/providers/database_provider.dart';

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return TemplateRepository(db);
});

class TemplatesNotifier extends AsyncNotifier<List<TemplateModel>> {
  @override
  Future<List<TemplateModel>> build() async {
    await ref.watch(databaseProvider.future);
    final repo = ref.watch(templateRepositoryProvider);
    return repo.getAll();
  }

  Future<int> createTemplate(TemplateModel template) async {
    final repo = ref.read(templateRepositoryProvider);
    final id = await repo.insert(template);
    ref.invalidateSelf();
    return id;
  }

  Future<void> addItem(TemplateItemModel item) async {
    final repo = ref.read(templateRepositoryProvider);
    await repo.insertItem(item);
    ref.invalidateSelf();
  }

  Future<void> deleteTemplate(int id) async {
    final repo = ref.read(templateRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }

  Future<void> deleteItem(int itemId) async {
    final repo = ref.read(templateRepositoryProvider);
    await repo.deleteItem(itemId);
    ref.invalidateSelf();
  }
}

final templatesProvider =
    AsyncNotifierProvider<TemplatesNotifier, List<TemplateModel>>(
      TemplatesNotifier.new,
    );

final templateItemsProvider =
    FutureProvider.family<List<TemplateItemModel>, int>((
      ref,
      templateId,
    ) async {
      await ref.watch(databaseProvider.future);
      final repo = ref.watch(templateRepositoryProvider);
      return repo.getItems(templateId);
    });
