// DailyCart - Database Migrations
import 'package:sqflite/sqflite.dart';
import 'package:dailycart/core/database/database_constants.dart';

class DatabaseMigrations {
  DatabaseMigrations._();

  static Future<void> createV1(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableCategories} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colName} TEXT NOT NULL,
        ${DbConstants.colIcon} TEXT,
        ${DbConstants.colIsDefault} INTEGER DEFAULT 0,
        ${DbConstants.colCreatedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableShoppingLists} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colName} TEXT NOT NULL,
        ${DbConstants.colBudget} REAL DEFAULT 0,
        ${DbConstants.colEstimatedTotal} REAL DEFAULT 0,
        ${DbConstants.colActualTotal} REAL DEFAULT 0,
        ${DbConstants.colStatus} TEXT DEFAULT '${DbConstants.statusActive}',
        ${DbConstants.colCreatedAt} TEXT NOT NULL,
        ${DbConstants.colUpdatedAt} TEXT NOT NULL,
        ${DbConstants.colCompletedAt} TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableGroceryItems} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colListId} INTEGER NOT NULL,
        ${DbConstants.colName} TEXT NOT NULL,
        ${DbConstants.colCategoryId} INTEGER,
        ${DbConstants.colQuantity} REAL DEFAULT 1,
        ${DbConstants.colUnit} TEXT DEFAULT 'piece',
        ${DbConstants.colUnitPrice} REAL DEFAULT 0,
        ${DbConstants.colActualUnitPrice} REAL DEFAULT 0,
        ${DbConstants.colTotalPrice} REAL DEFAULT 0,
        ${DbConstants.colActualTotalPrice} REAL DEFAULT 0,
        ${DbConstants.colNote} TEXT,
        ${DbConstants.colPriority} TEXT DEFAULT '${DbConstants.priorityNormal}',
        ${DbConstants.colSortOrder} INTEGER DEFAULT 0,
        ${DbConstants.colIsPurchased} INTEGER DEFAULT 0,
        ${DbConstants.colCreatedAt} TEXT NOT NULL,
        ${DbConstants.colUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DbConstants.colListId})
          REFERENCES ${DbConstants.tableShoppingLists}(${DbConstants.colId})
          ON DELETE CASCADE,
        FOREIGN KEY (${DbConstants.colCategoryId})
          REFERENCES ${DbConstants.tableCategories}(${DbConstants.colId})
          ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableFrequentItems} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colName} TEXT NOT NULL,
        ${DbConstants.colCategoryId} INTEGER,
        ${DbConstants.colDefaultQuantity} REAL DEFAULT 1,
        ${DbConstants.colDefaultUnit} TEXT DEFAULT 'piece',
        ${DbConstants.colDefaultPrice} REAL DEFAULT 0,
        ${DbConstants.colUsageCount} INTEGER DEFAULT 0,
        ${DbConstants.colLastUsedAt} TEXT,
        FOREIGN KEY (${DbConstants.colCategoryId})
          REFERENCES ${DbConstants.tableCategories}(${DbConstants.colId})
          ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableShoppingHistory} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colListName} TEXT NOT NULL,
        ${DbConstants.colTotalAmount} REAL DEFAULT 0,
        ${DbConstants.colItemCount} INTEGER DEFAULT 0,
        ${DbConstants.colCompletedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tablePriceHistory} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colItemName} TEXT NOT NULL,
        ${DbConstants.colCategoryId} INTEGER,
        ${DbConstants.colUnit} TEXT,
        ${DbConstants.colPrice} REAL NOT NULL,
        ${DbConstants.colRecordedAt} TEXT NOT NULL,
        FOREIGN KEY (${DbConstants.colCategoryId})
          REFERENCES ${DbConstants.tableCategories}(${DbConstants.colId})
          ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableTemplates} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colName} TEXT NOT NULL,
        ${DbConstants.colCreatedAt} TEXT NOT NULL,
        ${DbConstants.colUpdatedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableTemplateItems} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colTemplateId} INTEGER NOT NULL,
        ${DbConstants.colName} TEXT NOT NULL,
        ${DbConstants.colCategoryId} INTEGER,
        ${DbConstants.colQuantity} REAL DEFAULT 1,
        ${DbConstants.colUnit} TEXT DEFAULT 'piece',
        ${DbConstants.colDefaultPrice} REAL DEFAULT 0,
        FOREIGN KEY (${DbConstants.colTemplateId})
          REFERENCES ${DbConstants.tableTemplates}(${DbConstants.colId})
          ON DELETE CASCADE,
        FOREIGN KEY (${DbConstants.colCategoryId})
          REFERENCES ${DbConstants.tableCategories}(${DbConstants.colId})
          ON DELETE SET NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_gi_list ON ${DbConstants.tableGroceryItems}(${DbConstants.colListId})',
    );
    await db.execute(
      'CREATE INDEX idx_gi_cat ON ${DbConstants.tableGroceryItems}(${DbConstants.colCategoryId})',
    );
    await db.execute(
      'CREATE INDEX idx_fi_usage ON ${DbConstants.tableFrequentItems}(${DbConstants.colUsageCount})',
    );
    await db.execute(
      'CREATE INDEX idx_ph_name ON ${DbConstants.tablePriceHistory}(${DbConstants.colItemName})',
    );
    await db.execute(
      'CREATE INDEX idx_ti_template ON ${DbConstants.tableTemplateItems}(${DbConstants.colTemplateId})',
    );

    await _seedDefaultCategories(db);
    await _seedDefaultTemplates(db);
  }

  static Future<void> _seedDefaultCategories(Database db) async {
    final now = DateTime.now().toIso8601String();
    final categories = [
      {'name': 'Fruits', 'icon': '🍎'},
      {'name': 'Vegetables', 'icon': '🥦'},
      {'name': 'Dairy', 'icon': '🥛'},
      {'name': 'Bakery', 'icon': '🍞'},
      {'name': 'Meat', 'icon': '🥩'},
      {'name': 'Grains', 'icon': '🌾'},
      {'name': 'Snacks', 'icon': '🍿'},
      {'name': 'Beverages', 'icon': '🧃'},
      {'name': 'Spices', 'icon': '🌶️'},
      {'name': 'Frozen', 'icon': '🧊'},
      {'name': 'Household', 'icon': '🧹'},
      {'name': 'Personal Care', 'icon': '🧴'},
      {'name': 'Other', 'icon': '📦'},
    ];
    for (final cat in categories) {
      await db.insert(DbConstants.tableCategories, {
        'name': cat['name'],
        'icon': cat['icon'],
        'is_default': 1,
        'created_at': now,
      });
    }
  }

  static Future<void> _seedDefaultTemplates(Database db) async {
    final now = DateTime.now().toIso8601String();
    for (final name in [
      'Weekly Grocery',
      'Monthly Grocery',
      'Hostel Essentials',
      'Party Shopping',
      'Household',
    ]) {
      await db.insert(DbConstants.tableTemplates, {
        'name': name,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Future migrations: if (oldVersion < 2) await _migrateV1ToV2(db);
  }
}
