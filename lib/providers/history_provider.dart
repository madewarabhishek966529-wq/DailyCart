import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dailycart/models/shopping_history_model.dart';
import 'package:dailycart/repositories/history_repository.dart';
import 'package:dailycart/providers/database_provider.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return HistoryRepository(db);
});

class HistoryNotifier extends AsyncNotifier<List<ShoppingHistoryModel>> {
  @override
  Future<List<ShoppingHistoryModel>> build() async {
    await ref.watch(databaseProvider.future);
    final repo = ref.watch(historyRepositoryProvider);
    return repo.getAll();
  }

  Future<void> add(ShoppingHistoryModel entry) async {
    await ref.read(historyRepositoryProvider).insert(entry);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await ref.read(historyRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<ShoppingHistoryModel>>(
      HistoryNotifier.new,
    );

final monthlySpendProvider = FutureProvider.family<double, DateTime>((
  ref,
  month,
) async {
  await ref.watch(databaseProvider.future);
  final repo = ref.watch(historyRepositoryProvider);
  return repo.getMonthlyTotal(month);
});
