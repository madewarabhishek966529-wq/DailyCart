import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dailycart/models/grocery_item_model.dart';
import 'package:dailycart/models/price_history_model.dart';
import 'package:dailycart/repositories/grocery_item_repository.dart';
import 'package:dailycart/repositories/shopping_list_repository.dart';
import 'package:dailycart/repositories/frequent_item_repository.dart';
import 'package:dailycart/repositories/price_history_repository.dart';
import 'package:dailycart/providers/database_provider.dart';

final groceryItemRepositoryProvider = Provider<GroceryItemRepository>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return GroceryItemRepository(db);
});

final _listRepoProvider = Provider<ShoppingListRepository>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return ShoppingListRepository(db);
});

final _freqRepoProvider = Provider<FrequentItemRepository>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return FrequentItemRepository(db);
});

final _priceRepoProvider = Provider<PriceHistoryRepository>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return PriceHistoryRepository(db);
});

class GroceryItemsNotifier
    extends FamilyAsyncNotifier<List<GroceryItemModel>, int> {
  @override
  Future<List<GroceryItemModel>> build(int listId) async {
    await ref.watch(databaseProvider.future);
    final repo = ref.watch(groceryItemRepositoryProvider);
    return repo.getByListId(listId);
  }

  Future<void> add(GroceryItemModel item) async {
    final itemRepo = ref.read(groceryItemRepositoryProvider);
    final listRepo = ref.read(_listRepoProvider);
    final freqRepo = ref.read(_freqRepoProvider);
    final priceRepo = ref.read(_priceRepoProvider);
    await itemRepo.insert(item);
    await listRepo.recalculateTotals(item.listId);
    await freqRepo.recordUsage(
      name: item.name,
      categoryId: item.categoryId,
      quantity: item.quantity,
      unit: item.unit,
      price: item.unitPrice,
    );
    if (item.unitPrice > 0) {
      await priceRepo.record(
        PriceHistoryModel(
          itemName: item.name,
          categoryId: item.categoryId,
          unit: item.unit,
          price: item.unitPrice,
          recordedAt: DateTime.now(),
        ),
      );
    }
    ref.invalidateSelf();
  }

  Future<void> updateItem(GroceryItemModel item) async {
    final itemRepo = ref.read(groceryItemRepositoryProvider);
    final listRepo = ref.read(_listRepoProvider);
    await itemRepo.update(item);
    await listRepo.recalculateTotals(item.listId);
    ref.invalidateSelf();
  }

  Future<void> deleteItem(GroceryItemModel item) async {
    final itemRepo = ref.read(groceryItemRepositoryProvider);
    final listRepo = ref.read(_listRepoProvider);
    await itemRepo.delete(item.id!);
    await listRepo.recalculateTotals(item.listId);
    ref.invalidateSelf();
  }

  Future<void> togglePurchased(GroceryItemModel item) async {
    final itemRepo = ref.read(groceryItemRepositoryProvider);
    final listRepo = ref.read(_listRepoProvider);
    await itemRepo.togglePurchased(item.id!, !item.isPurchased);
    await listRepo.recalculateTotals(item.listId);
    ref.invalidateSelf();
  }

  Future<void> reorder(int listId, List<GroceryItemModel> reordered) async {
    final itemRepo = ref.read(groceryItemRepositoryProvider);
    final updates = <Map<String, int>>[];
    for (var i = 0; i < reordered.length; i++) {
      updates.add({'id': reordered[i].id!, 'sortOrder': i});
    }
    await itemRepo.updateSortOrders(updates);
    ref.invalidateSelf();
  }
}

final groceryItemsProvider =
    AsyncNotifierProviderFamily<
      GroceryItemsNotifier,
      List<GroceryItemModel>,
      int
    >(GroceryItemsNotifier.new);
