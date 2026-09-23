import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dailycart/core/database/database_service.dart';

final databaseProvider = FutureProvider<Database>((ref) async {
  return DatabaseService.instance.database;
});
