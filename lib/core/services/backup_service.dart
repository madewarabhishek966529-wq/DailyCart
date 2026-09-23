import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:dailycart/core/database/database_constants.dart';
import 'package:dailycart/core/database/database_service.dart';
import 'package:dailycart/core/errors/app_errors.dart';

class BackupService {
  BackupService._();
  static final BackupService instance = BackupService._();

  Future<String> exportFullJson() async {
    final db = await DatabaseService.instance.database;

    final lists = await db.query(DbConstants.tableShoppingLists);
    final items = await db.query(DbConstants.tableGroceryItems);
    final categories = await db.query(DbConstants.tableCategories);
    final frequent = await db.query(DbConstants.tableFrequentItems);
    final history = await db.query(DbConstants.tableShoppingHistory);
    final priceHistory = await db.query(DbConstants.tablePriceHistory);
    final templates = await db.query(DbConstants.tableTemplates);
    final templateItems = await db.query(DbConstants.tableTemplateItems);

    final payload = {
      'app': 'DailyCart',
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'tables': {
        DbConstants.tableShoppingLists: lists,
        DbConstants.tableGroceryItems: items,
        DbConstants.tableCategories: categories,
        DbConstants.tableFrequentItems: frequent,
        DbConstants.tableShoppingHistory: history,
        DbConstants.tablePriceHistory: priceHistory,
        DbConstants.tableTemplates: templates,
        DbConstants.tableTemplateItems: templateItems,
      },
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<void> restoreFromJson(String jsonContent) async {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(jsonContent) as Map<String, dynamic>;
    } catch (e) {
      throw const BackupError('Invalid JSON format.');
    }

    if (data['app'] != 'DailyCart') {
      throw const BackupError('Selected file is not a valid DailyCart backup.');
    }

    final tables = data['tables'] as Map<String, dynamic>?;
    if (tables == null) {
      throw const BackupError('No table data found in backup.');
    }

    final db = await DatabaseService.instance.database;

    await db.transaction((txn) async {
      // Clear tables in reverse dependency order
      await txn.delete(DbConstants.tableTemplateItems);
      await txn.delete(DbConstants.tableTemplates);
      await txn.delete(DbConstants.tablePriceHistory);
      await txn.delete(DbConstants.tableShoppingHistory);
      await txn.delete(DbConstants.tableFrequentItems);
      await txn.delete(DbConstants.tableGroceryItems);
      await txn.delete(DbConstants.tableShoppingLists);
      await txn.delete(DbConstants.tableCategories);

      // Restore categories
      final catRows = tables[DbConstants.tableCategories] as List<dynamic>?;
      if (catRows != null) {
        for (final row in catRows) {
          await txn.insert(
            DbConstants.tableCategories,
            Map<String, dynamic>.from(row as Map),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Restore shopping lists
      final listRows = tables[DbConstants.tableShoppingLists] as List<dynamic>?;
      if (listRows != null) {
        for (final row in listRows) {
          await txn.insert(
            DbConstants.tableShoppingLists,
            Map<String, dynamic>.from(row as Map),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Restore grocery items
      final itemRows = tables[DbConstants.tableGroceryItems] as List<dynamic>?;
      if (itemRows != null) {
        for (final row in itemRows) {
          await txn.insert(
            DbConstants.tableGroceryItems,
            Map<String, dynamic>.from(row as Map),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Restore frequent items
      final freqRows = tables[DbConstants.tableFrequentItems] as List<dynamic>?;
      if (freqRows != null) {
        for (final row in freqRows) {
          await txn.insert(
            DbConstants.tableFrequentItems,
            Map<String, dynamic>.from(row as Map),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Restore shopping history
      final histRows =
          tables[DbConstants.tableShoppingHistory] as List<dynamic>?;
      if (histRows != null) {
        for (final row in histRows) {
          await txn.insert(
            DbConstants.tableShoppingHistory,
            Map<String, dynamic>.from(row as Map),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Restore price history
      final priceRows = tables[DbConstants.tablePriceHistory] as List<dynamic>?;
      if (priceRows != null) {
        for (final row in priceRows) {
          await txn.insert(
            DbConstants.tablePriceHistory,
            Map<String, dynamic>.from(row as Map),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Restore templates
      final tempRows = tables[DbConstants.tableTemplates] as List<dynamic>?;
      if (tempRows != null) {
        for (final row in tempRows) {
          await txn.insert(
            DbConstants.tableTemplates,
            Map<String, dynamic>.from(row as Map),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Restore template items
      final tempItemRows =
          tables[DbConstants.tableTemplateItems] as List<dynamic>?;
      if (tempItemRows != null) {
        for (final row in tempItemRows) {
          await txn.insert(
            DbConstants.tableTemplateItems,
            Map<String, dynamic>.from(row as Map),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  Future<String> exportListCsv(int listId) async {
    final db = await DatabaseService.instance.database;

    final listRows = await db.query(
      DbConstants.tableShoppingLists,
      where: 'id = ?',
      whereArgs: [listId],
      limit: 1,
    );
    final listName = listRows.isNotEmpty
        ? (listRows.first['name'] as String)
        : 'Shopping List';

    final items = await db.rawQuery(
      '''
      SELECT gi.*, c.name as category_name
      FROM ${DbConstants.tableGroceryItems} gi
      LEFT JOIN ${DbConstants.tableCategories} c ON c.id = gi.category_id
      WHERE gi.list_id = ?
      ORDER BY gi.is_purchased ASC, gi.sort_order ASC
    ''',
      [listId],
    );

    final buffer = StringBuffer();
    buffer.writeln('# DailyCart Export - $listName');
    buffer.writeln(
      'Item Name,Category,Quantity,Unit,Unit Price,Total Price,Purchased,Note',
    );

    for (final itm in items) {
      final name = _escapeCsv(itm['name'] as String? ?? '');
      final cat = _escapeCsv(itm['category_name'] as String? ?? 'Other');
      final qty = itm['quantity'] ?? 1;
      final unit = _escapeCsv(itm['unit'] as String? ?? 'piece');
      final unitPrice = itm['unit_price'] ?? 0;
      final totalPrice = itm['total_price'] ?? 0;
      final isPurchased = (itm['is_purchased'] as int? ?? 0) == 1
          ? 'Yes'
          : 'No';
      final note = _escapeCsv(itm['note'] as String? ?? '');

      buffer.writeln(
        '$name,$cat,$qty,$unit,$unitPrice,$totalPrice,$isPurchased,$note',
      );
    }

    return buffer.toString();
  }

  String _escapeCsv(String val) {
    if (val.contains(',') || val.contains('"') || val.contains('\n')) {
      return '"${val.replaceAll('"', '""')}"';
    }
    return val;
  }
}
