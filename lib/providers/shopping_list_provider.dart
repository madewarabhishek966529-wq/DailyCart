import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dailycart/models/shopping_list_model.dart';
import 'package:dailycart/repositories/shopping_list_repository.dart';
import 'package:dailycart/providers/database_provider.dart';

final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return ShoppingListRepository(db);
});

class ShoppingListsNotifier extends AsyncNotifier<List<ShoppingListModel>> {
  @override
  Future<List<ShoppingListModel>> build() async {
    await ref.watch(databaseProvider.future);
    final repo = ref.watch(shoppingListRepositoryProvider);
    return repo.getAll();
  }

  Future<int> create(ShoppingListModel list) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    final id = await repo.insert(list);
    ref.invalidateSelf();
    return id;
  }

  Future<void> updateList(ShoppingListModel list) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    await repo.update(list);
    ref.invalidateSelf();
  }

  Future<void> deleteList(int id) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }

  Future<int> duplicate(int id) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    final newId = await repo.duplicate(id);
    ref.invalidateSelf();
    return newId;
  }

  Future<void> archive(int id) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    final list = await repo.getById(id);
    if (list == null) return;
    await repo.update(
      list.copyWith(status: ListStatus.archived, updatedAt: DateTime.now()),
    );
    ref.invalidateSelf();
  }

  Future<void> complete(int id) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    final list = await repo.getById(id);
    if (list == null) return;
    final now = DateTime.now();
    await repo.update(
      list.copyWith(
        status: ListStatus.completed,
        completedAt: now,
        updatedAt: now,
      ),
    );
    ref.invalidateSelf();
  }

  Future<void> reopen(int id) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    final list = await repo.getById(id);
    if (list == null) return;
    await repo.update(
      list.copyWith(
        status: ListStatus.active,
        clearCompletedAt: true,
        updatedAt: DateTime.now(),
      ),
    );
    ref.invalidateSelf();
  }
}

final shoppingListsProvider =
    AsyncNotifierProvider<ShoppingListsNotifier, List<ShoppingListModel>>(
      ShoppingListsNotifier.new,
    );

final shoppingListByIdProvider = FutureProvider.family<ShoppingListModel?, int>(
  (ref, id) async {
    await ref.watch(databaseProvider.future);
    final repo = ref.watch(shoppingListRepositoryProvider);
    return repo.getById(id);
  },
);
