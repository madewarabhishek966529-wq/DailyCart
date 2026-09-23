import 'package:sqflite/sqflite.dart';
import 'package:dailycart/core/database/database_constants.dart';
import 'package:dailycart/core/errors/app_errors.dart';
import 'package:dailycart/models/category_model.dart';

class CategoryRepository {
  const CategoryRepository(this._db);
  final Database _db;

  Future<List<CategoryModel>> getAll() async {
    try {
      final rows = await _db.query(
        DbConstants.tableCategories,
        orderBy: '${DbConstants.colIsDefault} DESC, ${DbConstants.colName} ASC',
      );
      return rows.map(CategoryModel.fromMap).toList();
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<CategoryModel?> getById(int id) async {
    try {
      final rows = await _db.query(
        DbConstants.tableCategories,
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      return rows.isEmpty ? null : CategoryModel.fromMap(rows.first);
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<int> insert(CategoryModel category) async {
    try {
      return await _db.insert(
        DbConstants.tableCategories,
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<void> update(CategoryModel category) async {
    try {
      await _db.update(
        DbConstants.tableCategories,
        category.toMap(),
        where: '${DbConstants.colId} = ?',
        whereArgs: [category.id],
      );
    } catch (e) {
      throw mapDbException(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      final cat = await getById(id);
      if (cat?.isDefault == true) {
        throw const ValidationError('Default categories cannot be deleted.');
      }
      await _db.delete(
        DbConstants.tableCategories,
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw mapDbException(e);
    }
  }
}
