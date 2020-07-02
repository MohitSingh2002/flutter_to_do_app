import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelperClass {
  static final _dbName = "sqflite.db";
  static final _dbVersion = 1;

  static final tableName = "my_table";

  static final columnId = "id";
  static final columnName = "name";
  static final columnDate = "date";
  static final columnStatus = "status";

  static Database _database;

  DatabaseHelperClass._privateConstructor();
  static final DatabaseHelperClass instance = DatabaseHelperClass._privateConstructor();

  Future<Database> get database async {
    if(_database != null) {
      return _database;
    }

    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnDate TEXT NOT NULL,
      $columnStatus TEXT NOT NULL
      )
      ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.database;
    return await db.query(tableName);
  }

//  Future<List<Map<String, dynamic>>> queryspecific(int id) async {
//    Database db = await instance.database;
//    var result = await db.query(tableName, where: "id = ?", whereArgs: [id]);
//    return result;
//  }

  Future<int> deleteSpecific(int id) async {
    Database db = await instance.database;
    var result = await db.delete(tableName, where: "id = ?", whereArgs: [id]);
    return result;
  }

  Future<int> updateSpecific(String name, String status,int id) async {
    Database db = await instance.database;
    var result = await db.update(tableName, {"name" : name, "status": status,}, where: "id = ?", whereArgs: [id]);
    return result;
  }

}
