import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dailycart/models/category_model.dart';
import 'package:dailycart/repositories/category_repository.dart';
import 'package:dailycart/providers/database_provider.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return CategoryRepository(db);
});

class CategoriesNotifier extends AsyncNotifier<List<CategoryModel>> {
  @override
  Future<List<CategoryModel>> build() async {
    await ref.watch(databaseProvider.future);
    final repo = ref.watch(categoryRepositoryProvider);
    return repo.getAll();
  }

  Future<void> add(CategoryModel category) async {
    await ref.read(categoryRepositoryProvider).insert(category);
    ref.invalidateSelf();
  }

  Future<void> updateCategory(CategoryModel category) async {
    await ref.read(categoryRepositoryProvider).update(category);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await ref.read(categoryRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<CategoryModel>>(
      CategoriesNotifier.new,
    );
