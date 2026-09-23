import 'package:sqflite/sqflite.dart';
import 'package:dailycart/core/database/database_constants.dart';
import 'package:dailycart/core/errors/app_errors.dart';
import 'package:dailycart/models/shopping_history_model.dart';

class HistoryRepository {
  const HistoryRepository(this._db);
  final Database _db;

  Future<List<ShoppingHistoryModel>> getAll() async {
    try {
      final rows = await _db.query(
        DbConstants.tableShoppingHistory,
        orderBy: '${DbConstants.colCompletedAt} DESC',
      );
      return rows.map(ShoppingHistoryModel.fromMap).toList();
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<ShoppingHistoryModel?> getById(int id) async {
    try {
      final rows = await _db.query(
        DbConstants.tableShoppingHistory,
        where: '${DbConstants.colId}=?',
        whereArgs: [id],
        limit: 1,
      );
      return rows.isEmpty ? null : ShoppingHistoryModel.fromMap(rows.first);
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<int> insert(ShoppingHistoryModel history) async {
    try {
      return await _db.insert(
        DbConstants.tableShoppingHistory,
        history.toMap(),
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _db.delete(
        DbConstants.tableShoppingHistory,
        where: '${DbConstants.colId}=?',
        whereArgs: [id],
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<double> getMonthlyTotal(DateTime month) async {
    try {
      final start = DateTime(month.year, month.month).toIso8601String();
      final end = DateTime(month.year, month.month + 1).toIso8601String();
      final rows = await _db.rawQuery(
        'SELECT COALESCE(SUM(total_amount),0) AS t FROM ${DbConstants.tableShoppingHistory} WHERE completed_at>=? AND completed_at<?',
        [start, end],
      );
      return (rows.first['t'] as num? ?? 0).toDouble();
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<List<ShoppingHistoryModel>> getRecent(int months) async {
    try {
      final cutoff = DateTime.now()
          .subtract(Duration(days: months * 30))
          .toIso8601String();
      final rows = await _db.query(
        DbConstants.tableShoppingHistory,
        where: '${DbConstants.colCompletedAt}>=?',
        whereArgs: [cutoff],
        orderBy: '${DbConstants.colCompletedAt} DESC',
      );
      return rows.map(ShoppingHistoryModel.fromMap).toList();
    } catch (e) {
      throw mapDbException(e);
    }
  }
}
