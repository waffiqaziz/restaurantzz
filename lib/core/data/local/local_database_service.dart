import 'package:flutter/foundation.dart';
import 'package:restaurantzz/core/data/model/restaurant.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class LocalDatabaseService {
  static const String _databaseName = 'restaurantzz.db';
  static const String _tableName = 'restaurant';
  static const int _version = 1;
  static Database? _db;

  Future<Database> _initializeDb() async {
    if (_db != null) {
      return _db!;
    }

    // use factory based on the platform
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    _db = await openDatabase(_databaseName, version: _version);

    await _ensureTableExists(_db!);

    return _db!;
  }

  Future<void> _ensureTableExists(Database db) async {
    // Use CREATE TABLE IF NOT EXISTS to ensure table creation
    const query = """
      CREATE TABLE IF NOT EXISTS $_tableName(
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        pictureId TEXT,
        city TEXT,
        rating REAL
      )
    """;
    await db.execute(query);
  }

  Future<int> insertItem(Restaurant restaurant) async {
    final db = await _initializeDb();

    final data = restaurant.toJson();
    final id = await db.insert(
      _tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<List<Restaurant>> getAllItems() async {
    final db = await _initializeDb();
    final results = await db.query(_tableName);

    return results.map((result) => Restaurant.fromJson(result)).toList();
  }

  Future<Restaurant> getItemById(String id) async {
    final db = await _initializeDb();
    final results =
        await db.query(_tableName, where: "id = ?", whereArgs: [id], limit: 1);

    if (results.isEmpty) {
      throw Exception("No restaurant found with id: $id");
    }
    return results.map((result) => Restaurant.fromJson(result)).first;
  }

  Future<int> removeItem(String id) async {
    final db = await _initializeDb();

    final result =
        await db.delete(_tableName, where: "id = ?", whereArgs: [id]);
    return result;
  }

  @visibleForTesting
  Future<void> clearDatabase() async {
    final db = await _initializeDb();
    await db.delete(_tableName);
  }

  @visibleForTesting
  Future<Database> get database async => _initializeDb();
}
