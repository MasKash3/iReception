import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'person.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
  static Database? _database; // Singleton Database

  String personTable = 'person';
  String colName = 'name';
  String colDepartment = 'department';
  String colPosition = 'position';
  String colEmail = 'email';
  String colemployeeNumber = 'employeeNumber';
  String coltimeIn = 'timeIn';
  String colFaceJpg = 'faceJpg';
  String colTemplates = 'templates';

  DatabaseHelper._createInstance(); // constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'employees.db');
    var database = await openDatabase(path, version: 1, onCreate: _createDb);
    return database;
  }

  void _createDb(Database db, int newVersion) async {
    await db.transaction((txn) async {
      // Create the table
      await txn.execute('''
      CREATE TABLE $personTable (
        $colName TEXT,
        $colDepartment TEXT,
        $colPosition TEXT,
        $colEmail TEXT,
        $colemployeeNumber TEXT,
        $coltimeIn TEXT,
        $colFaceJpg BLOB,
        $colTemplates BLOB
      )
    ''');
    });
  }

  // CRUD operations

  Future<int> insertPerson(Person person) async {
    try {
      Database db = await database;
      var result = await db.insert(personTable, person.toMap());
      // print("Result1 is: $result");
      return result;
    } catch (e) {
      print("Exception during insertion is: $e");
      return -1;
    }
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

  Future<int> deletePerson(String name) async {
    Database db = await database;
    int result = await db.delete(
      personTable,
      where: '$colName = ?',
      whereArgs: [name],
    );
    return result;
  }
}
