import 'package:sqflite/sqflite.dart';
import 'package:dailycart/core/database/database_constants.dart';
import 'package:dailycart/core/errors/app_errors.dart';
import 'package:dailycart/core/utils/app_date_utils.dart';
import 'package:dailycart/models/shopping_list_model.dart';

class ShoppingListRepository {
  const ShoppingListRepository(this._db);
  final Database _db;

  Future<List<ShoppingListModel>> getAll({String? status}) async {
    try {
      final where = status != null ? 'sl.${DbConstants.colStatus} = ?' : null;
      final whereArgs = status != null ? [status] : null;
      final rows = await _db.rawQuery('''
        SELECT sl.*,
          COALESCE(COUNT(gi.id), 0) AS item_count,
          COALESCE(SUM(CASE WHEN gi.is_purchased = 1 THEN 1 ELSE 0 END), 0) AS completed_count
        FROM ${DbConstants.tableShoppingLists} sl
        LEFT JOIN ${DbConstants.tableGroceryItems} gi ON gi.list_id = sl.id
        ${where != null ? 'WHERE $where' : ''}
        GROUP BY sl.id
        ORDER BY sl.updated_at DESC
      ''', whereArgs);
      return rows.map(ShoppingListModel.fromMap).toList();
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<ShoppingListModel?> getById(int id) async {
    try {
      final rows = await _db.rawQuery(
        '''
        SELECT sl.*,
          COALESCE(COUNT(gi.id), 0) AS item_count,
          COALESCE(SUM(CASE WHEN gi.is_purchased = 1 THEN 1 ELSE 0 END), 0) AS completed_count
        FROM ${DbConstants.tableShoppingLists} sl
        LEFT JOIN ${DbConstants.tableGroceryItems} gi ON gi.list_id = sl.id
        WHERE sl.id = ? GROUP BY sl.id
      ''',
        [id],
      );
      return rows.isEmpty ? null : ShoppingListModel.fromMap(rows.first);
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<int> insert(ShoppingListModel list) async {
    try {
      return await _db.insert(
        DbConstants.tableShoppingLists,
        list.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<void> update(ShoppingListModel list) async {
    try {
      await _db.update(
        DbConstants.tableShoppingLists,
        list.copyWith(updatedAt: DateTime.now()).toMap(),
        where: '${DbConstants.colId} = ?',
        whereArgs: [list.id],
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _db.delete(
        DbConstants.tableShoppingLists,
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<int> duplicate(int id) async {
    try {
      return await _db.transaction((txn) async {
        final rows = await txn.query(
          DbConstants.tableShoppingLists,
          where: '${DbConstants.colId} = ?',
          whereArgs: [id],
          limit: 1,
        );
        if (rows.isEmpty) throw const NotFoundError('List not found.');
        final orig = ShoppingListModel.fromMap(rows.first);
        final now = DateTime.now();
        final newList = orig.copyWith(
          id: null,
          name: '${orig.name} (Copy)',
          status: ListStatus.active,
          estimatedTotal: 0,
          actualTotal: 0,
          clearCompletedAt: true,
          createdAt: now,
          updatedAt: now,
        );
        final newId = await txn.insert(
          DbConstants.tableShoppingLists,
          newList.toMap(),
        );
        final items = await txn.query(
          DbConstants.tableGroceryItems,
          where: '${DbConstants.colListId} = ?',
          whereArgs: [id],
        );
        for (final item in items) {
          final m = Map<String, dynamic>.from(item);
          m.remove(DbConstants.colId);
          m[DbConstants.colListId] = newId;
          m[DbConstants.colIsPurchased] = 0;
          m[DbConstants.colActualUnitPrice] = 0.0;
          m[DbConstants.colActualTotalPrice] = 0.0;
          m[DbConstants.colCreatedAt] = now.toIso8601String();
          m[DbConstants.colUpdatedAt] = now.toIso8601String();
          await txn.insert(DbConstants.tableGroceryItems, m);
        }
        final totalRow = await txn.rawQuery(
          'SELECT COALESCE(SUM(total_price),0) AS t FROM ${DbConstants.tableGroceryItems} WHERE list_id=?',
          [newId],
        );
        final total = (totalRow.first['t'] as num? ?? 0).toDouble();
        await txn.update(
          DbConstants.tableShoppingLists,
          {DbConstants.colEstimatedTotal: total},
          where: '${DbConstants.colId} = ?',
          whereArgs: [newId],
        );
        return newId;
      });
    } catch (e) {
      if (e is AppError) rethrow;
      throw mapDbException(e);
    }
  }

  Future<void> recalculateTotals(int listId) async {
    try {
      final rows = await _db.rawQuery(
        '''
        SELECT
          COALESCE(SUM(total_price), 0) AS estimated,
          COALESCE(SUM(CASE WHEN is_purchased=1 THEN actual_total_price ELSE 0 END), 0) AS actual
        FROM ${DbConstants.tableGroceryItems} WHERE list_id=?
      ''',
        [listId],
      );
      final est = (rows.first['estimated'] as num? ?? 0).toDouble();
      final act = (rows.first['actual'] as num? ?? 0).toDouble();
      await _db.update(
        DbConstants.tableShoppingLists,
        {
          DbConstants.colEstimatedTotal: est,
          DbConstants.colActualTotal: act,
          DbConstants.colUpdatedAt: AppDateUtils.nowIso(),
        },
        where: '${DbConstants.colId}=?',
        whereArgs: [listId],
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }
}
