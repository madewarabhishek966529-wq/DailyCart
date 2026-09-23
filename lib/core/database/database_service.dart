// DailyCart - Database Service
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dailycart/core/database/database_constants.dart';
import 'package:dailycart/core/database/database_migrations.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();
  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DbConstants.dbName);
    return openDatabase(
      path,
      version: DbConstants.dbVersion,
      onCreate: (db, version) async {
        await DatabaseMigrations.createV1(db);
        debugPrint('[DB] Created at version $version');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await DatabaseMigrations.onUpgrade(db, oldVersion, newVersion);
        debugPrint('[DB] Upgraded $oldVersion -> $newVersion');
      },
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<T> runTransaction<T>(
    Future<T> Function(Transaction txn) action,
  ) async {
    final db = await database;
    return db.transaction(action);
  }
}
