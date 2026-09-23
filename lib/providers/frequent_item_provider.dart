import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dailycart/models/frequent_item_model.dart';
import 'package:dailycart/repositories/frequent_item_repository.dart';
import 'package:dailycart/providers/database_provider.dart';

final frequentItemRepositoryProvider = Provider<FrequentItemRepository>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return FrequentItemRepository(db);
});

final frequentItemsProvider = FutureProvider<List<FrequentItemModel>>((
  ref,
) async {
  await ref.watch(databaseProvider.future);
  final repo = ref.watch(frequentItemRepositoryProvider);
  return repo.getTop(20);
});

final frequentItemSearchProvider =
    FutureProvider.family<List<FrequentItemModel>, String>((ref, query) async {
      await ref.watch(databaseProvider.future);
      final repo = ref.watch(frequentItemRepositoryProvider);
      if (query.trim().isEmpty) return repo.getTop(20);
      return repo.search(query);
    });
