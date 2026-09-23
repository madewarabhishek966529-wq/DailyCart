import 'package:sqflite/sqflite.dart';
import 'package:dailycart/core/database/database_constants.dart';
import 'package:dailycart/core/errors/app_errors.dart';
import 'package:dailycart/models/template_model.dart';
import 'package:dailycart/models/template_item_model.dart';
import 'package:dailycart/models/grocery_item_model.dart';
import 'package:dailycart/models/shopping_list_model.dart';

class TemplateRepository {
  const TemplateRepository(this._db);
  final Database _db;

  Future<List<TemplateModel>> getAll() async {
    try {
      final rows = await _db.rawQuery('''
        SELECT t.*, COUNT(ti.id) AS item_count
        FROM ${DbConstants.tableTemplates} t
        LEFT JOIN ${DbConstants.tableTemplateItems} ti ON ti.template_id = t.id
        GROUP BY t.id ORDER BY t.name ASC
      ''');
      return rows.map(TemplateModel.fromMap).toList();
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<List<TemplateItemModel>> getItems(int templateId) async {
    try {
      final rows = await _db.query(
        DbConstants.tableTemplateItems,
        where: '${DbConstants.colTemplateId}=?',
        whereArgs: [templateId],
        orderBy: '${DbConstants.colName} ASC',
      );
      return rows.map(TemplateItemModel.fromMap).toList();
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<int> insert(TemplateModel template) async {
    try {
      return await _db.insert(
        DbConstants.tableTemplates,
        template.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<void> insertItem(TemplateItemModel item) async {
    try {
      await _db.insert(
        DbConstants.tableTemplateItems,
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<void> update(TemplateModel template) async {
    try {
      await _db.update(
        DbConstants.tableTemplates,
        template.copyWith(updatedAt: DateTime.now()).toMap(),
        where: '${DbConstants.colId}=?',
        whereArgs: [template.id],
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _db.delete(
        DbConstants.tableTemplates,
        where: '${DbConstants.colId}=?',
        whereArgs: [id],
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<void> deleteItem(int itemId) async {
    try {
      await _db.delete(
        DbConstants.tableTemplateItems,
        where: '${DbConstants.colId}=?',
        whereArgs: [itemId],
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<int> createListFromTemplate(int templateId, String listName) async {
    try {
      return await _db.transaction((txn) async {
        final now = DateTime.now();
        final newListId = await txn.insert(
          DbConstants.tableShoppingLists,
          ShoppingListModel(
            name: listName,
            createdAt: now,
            updatedAt: now,
          ).toMap(),
        );
        final items = await txn.query(
          DbConstants.tableTemplateItems,
          where: '${DbConstants.colTemplateId}=?',
          whereArgs: [templateId],
        );
        for (var i = 0; i < items.length; i++) {
          final ti = TemplateItemModel.fromMap(items[i]);
          await txn.insert(
            DbConstants.tableGroceryItems,
            GroceryItemModel(
              listId: newListId,
              name: ti.name,
              categoryId: ti.categoryId,
              quantity: ti.quantity,
              unit: ti.unit,
              unitPrice: ti.defaultPrice,
              totalPrice: ti.quantity * ti.defaultPrice,
              sortOrder: i,
              createdAt: now,
              updatedAt: now,
            ).toMap(),
          );
        }
        return newListId;
      });
    } catch (e) {
      if (e is AppError) rethrow;
      throw mapDbException(e);
    }
  }

  Future<int> buyAgain(int sourceListId, String newListName) async {
    try {
      return await _db.transaction((txn) async {
        final now = DateTime.now();
        final newListId = await txn.insert(
          DbConstants.tableShoppingLists,
          ShoppingListModel(
            name: newListName,
            createdAt: now,
            updatedAt: now,
          ).toMap(),
        );
        final items = await txn.query(
          DbConstants.tableGroceryItems,
          where: '${DbConstants.colListId}=?',
          whereArgs: [sourceListId],
        );
        for (var i = 0; i < items.length; i++) {
          final orig = GroceryItemModel.fromMap(items[i]);
          await txn.insert(
            DbConstants.tableGroceryItems,
            orig
                .copyWith(
                  id: null,
                  listId: newListId,
                  isPurchased: false,
                  actualUnitPrice: 0,
                  actualTotalPrice: 0,
                  sortOrder: i,
                  createdAt: now,
                  updatedAt: now,
                )
                .toMap(),
          );
        }
        return newListId;
      });
    } catch (e) {
      if (e is AppError) rethrow;
      throw mapDbException(e);
    }
  }
}
