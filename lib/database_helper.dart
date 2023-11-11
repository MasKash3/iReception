import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'person.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
  static Database? _database; // Singleton Database

  String personTable = 'person';
  String colId = 'id';
  String colName = 'name';
  String colFaceJpg = 'faceJpg';
  String colTemplates = 'templates';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'person.db');
    var database = await openDatabase(path, version: 1, onCreate: _createDb);
    return database;
  }

  void _createDb(Database db, int newVersion) async {
    await db.transaction((txn) async {
      // Drop the table if it exists
      await txn.execute('DROP TABLE IF EXISTS $personTable');

      // Create the table
      await txn.execute('''
      CREATE TABLE $personTable (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colName TEXT,
        $colFaceJpg BLOB,
        $colTemplates BLOB
      )
    ''');
    }).then((_) {
      print("Table created successfully.");
    }).catchError((error) {
      print("Error Occurred: $error");
    });
  }

  // CRUD operations

  Future<int> insertPerson(Person person) async {
    Database db = await database;
    var result = await db.insert(personTable, person.toMap());
    return result;
  }

  Future<List<Person>> getPersonsList() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(personTable);
    List<Person> persons = [];
    if (maps.isNotEmpty) {
      for (Map<String, dynamic> map in maps) {
        persons.add(Person.fromMap(map));
      }
    }
    return persons;
  }

  Future<int> deletePerson(int id) async {
    Database db = await database;
    int result = await db.delete(
      personTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }
}
