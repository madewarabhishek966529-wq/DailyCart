import 'package:sqflite/sqflite.dart';
import 'package:dailycart/core/database/database_constants.dart';
import 'package:dailycart/core/errors/app_errors.dart';
import 'package:dailycart/core/utils/app_date_utils.dart';
import 'package:dailycart/models/grocery_item_model.dart';

class GroceryItemRepository {
  const GroceryItemRepository(this._db);
  final Database _db;

  Future<List<GroceryItemModel>> getByListId(int listId) async {
    try {
      final rows = await _db.rawQuery(
        '''
        SELECT gi.*, c.name AS category_name
        FROM ${DbConstants.tableGroceryItems} gi
        LEFT JOIN ${DbConstants.tableCategories} c ON c.id = gi.category_id
        WHERE gi.list_id = ?
        ORDER BY gi.sort_order ASC, gi.created_at ASC
      ''',
        [listId],
      );
      return rows.map(GroceryItemModel.fromMap).toList();
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<GroceryItemModel?> getById(int id) async {
    try {
      final rows = await _db.rawQuery(
        '''
        SELECT gi.*, c.name AS category_name
        FROM ${DbConstants.tableGroceryItems} gi
        LEFT JOIN ${DbConstants.tableCategories} c ON c.id = gi.category_id
        WHERE gi.id = ? LIMIT 1
      ''',
        [id],
      );
      return rows.isEmpty ? null : GroceryItemModel.fromMap(rows.first);
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<int> insert(GroceryItemModel item) async {
    try {
      return await _db.insert(
        DbConstants.tableGroceryItems,
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<void> update(GroceryItemModel item) async {
    try {
      await _db.update(
        DbConstants.tableGroceryItems,
        item.copyWith(updatedAt: DateTime.now()).toMap(),
        where: '${DbConstants.colId}=?',
        whereArgs: [item.id],
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _db.delete(
        DbConstants.tableGroceryItems,
        where: '${DbConstants.colId}=?',
        whereArgs: [id],
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<void> togglePurchased(int id, bool purchased) async {
    try {
      await _db.update(
        DbConstants.tableGroceryItems,
        {
          DbConstants.colIsPurchased: purchased ? 1 : 0,
          DbConstants.colUpdatedAt: AppDateUtils.nowIso(),
        },
        where: '${DbConstants.colId}=?',
        whereArgs: [id],
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<void> updateSortOrders(List<Map<String, int>> updates) async {
    try {
      await _db.transaction((txn) async {
        for (final u in updates) {
          await txn.update(
            DbConstants.tableGroceryItems,
            {DbConstants.colSortOrder: u['sortOrder']},
            where: '${DbConstants.colId}=?',
            whereArgs: [u['id']],
          );
        }
      });
    } catch (e) {
      throw mapDbException(e);
    }
  }
}
