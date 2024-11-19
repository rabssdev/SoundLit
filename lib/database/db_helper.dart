import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/light.dart';
import '../models/state.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Light (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            number INTEGER NOT NULL,
            state INTEGER NOT NULL,
            channel_number INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE State (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            channel_list TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // CRUD Operations for Light
  Future<int> insertLight(Light light) async {
    final db = await database;
    return await db.insert('Light', light.toMap());
  }

Future<List<Light>> getAllLights() async {
  final db = await database;
  final result = await db.query('Light');

  if (result.isEmpty) {
    // Retourner une liste vide si aucun résultat
    return [];
  }

  // Mappez les résultats uniquement si non vide
  return result.map((map) => Light.fromMap(map)).toList();
}


  Future<int> updateLight(Light light) async {
    final db = await database;
    return await db.update(
      'Light',
      light.toMap(),
      where: 'id = ?',
      whereArgs: [light.id],
    );
  }

  Future<int> deleteLight(int id) async {
    final db = await database;
    return await db.delete('Light', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Operations for State
  Future<int> insertState(StateModel state) async {
    final db = await database;
    return await db.insert('State', state.toMap());
  }

  Future<List<StateModel>> getAllStates() async {
    final db = await database;
    final result = await db.query('State');
    return result.map((map) => StateModel.fromMap(map)).toList();
  }

  Future<int> updateState(StateModel state) async {
    final db = await database;
    return await db.update(
      'State',
      state.toMap(),
      where: 'id = ?',
      whereArgs: [state.id],
    );
  }

  Future<int> deleteState(int id) async {
    final db = await database;
    return await db.delete('State', where: 'id = ?', whereArgs: [id]);
  }
}
