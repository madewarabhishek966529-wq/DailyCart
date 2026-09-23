import 'package:sqflite/sqflite.dart';
import 'package:dailycart/core/database/database_constants.dart';
import 'package:dailycart/core/errors/app_errors.dart';
import 'package:dailycart/models/price_history_model.dart';

class PriceHistoryRepository {
  const PriceHistoryRepository(this._db);
  final Database _db;

  Future<void> record(PriceHistoryModel entry) async {
    try {
      await _db.insert(
        DbConstants.tablePriceHistory,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<PriceHistoryModel?> getLastPrice(String itemName) async {
    try {
      final rows = await _db.query(
        DbConstants.tablePriceHistory,
        where: 'LOWER(${DbConstants.colItemName})=LOWER(?)',
        whereArgs: [itemName],
        orderBy: '${DbConstants.colRecordedAt} DESC',
        limit: 1,
      );
      return rows.isEmpty ? null : PriceHistoryModel.fromMap(rows.first);
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<List<PriceHistoryModel>> getByItemName(String itemName) async {
    try {
      final rows = await _db.query(
        DbConstants.tablePriceHistory,
        where: 'LOWER(${DbConstants.colItemName})=LOWER(?)',
        whereArgs: [itemName],
        orderBy: '${DbConstants.colRecordedAt} DESC',
        limit: 10,
      );
      return rows.map(PriceHistoryModel.fromMap).toList();
    } catch (e) {
      throw mapDbException(e);
    }
  }
}
