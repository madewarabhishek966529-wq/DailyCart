import 'package:sqflite/sqflite.dart';
import 'package:dailycart/core/database/database_constants.dart';
import 'package:dailycart/core/errors/app_errors.dart';
import 'package:dailycart/core/utils/app_date_utils.dart';
import 'package:dailycart/models/frequent_item_model.dart';

class FrequentItemRepository {
  const FrequentItemRepository(this._db);
  final Database _db;

  Future<List<FrequentItemModel>> getTop(int limit) async {
    try {
      final rows = await _db.query(
        DbConstants.tableFrequentItems,
        orderBy:
            '${DbConstants.colUsageCount} DESC, ${DbConstants.colLastUsedAt} DESC',
        limit: limit,
      );
      return rows.map(FrequentItemModel.fromMap).toList();
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<List<FrequentItemModel>> search(String query) async {
    try {
      final rows = await _db.query(
        DbConstants.tableFrequentItems,
        where: '${DbConstants.colName} LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: '${DbConstants.colUsageCount} DESC',
        limit: 20,
      );
      return rows.map(FrequentItemModel.fromMap).toList();
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<void> recordUsage({
    required String name,
    int? categoryId,
    double quantity = 1,
    String unit = 'piece',
    double price = 0,
  }) async {
    try {
      final existing = await _db.query(
        DbConstants.tableFrequentItems,
        where: 'LOWER(${DbConstants.colName}) = LOWER(?)',
        whereArgs: [name],
        limit: 1,
      );
      final now = AppDateUtils.nowIso();
      if (existing.isNotEmpty) {
        final current = FrequentItemModel.fromMap(existing.first);
        await _db.update(
          DbConstants.tableFrequentItems,
          {
            DbConstants.colUsageCount: current.usageCount + 1,
            DbConstants.colLastUsedAt: now,
            DbConstants.colDefaultQuantity: quantity,
            DbConstants.colDefaultUnit: unit,
            if (price > 0) DbConstants.colDefaultPrice: price,
          },
          where: '${DbConstants.colId}=?',
          whereArgs: [current.id],
        );
      } else {
        await _db.insert(DbConstants.tableFrequentItems, {
          DbConstants.colName: name,
          DbConstants.colCategoryId: categoryId,
          DbConstants.colDefaultQuantity: quantity,
          DbConstants.colDefaultUnit: unit,
          DbConstants.colDefaultPrice: price,
          DbConstants.colUsageCount: 1,
          DbConstants.colLastUsedAt: now,
        });
      }
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _db.delete(
        DbConstants.tableFrequentItems,
        where: '${DbConstants.colId}=?',
        whereArgs: [id],
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }
}
