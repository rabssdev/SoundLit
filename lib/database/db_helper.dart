import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/light.dart';
import '../models/statu.dart';
import '../models/tools.dart';
import '../models/model.dart';
import '../models/used_light.dart';

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
            statu INTEGER NOT NULL,
            channel_list TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE Statu (
            statu_id INTEGER PRIMARY KEY AUTOINCREMENT,
            channels TEXT NOT NULL,
            activated INTEGER NOT NULL,
            delay_after INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE Tools (
            tools_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            ch_used INTEGER NOT NULL,
            label TEXT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE Model (
            model_id INTEGER PRIMARY KEY AUTOINCREMENT,
            ref TEXT NOT NULL,
            ch_number INTEGER NOT NULL,
            ch_tool TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE UsedLight (
            used_light_id INTEGER PRIMARY KEY AUTOINCREMENT,
            model_id INTEGER NOT NULL,
            activated INTEGER NOT NULL,
            channels TEXT NOT NULL,
            FOREIGN KEY (model_id) REFERENCES Model(model_id)
          )
        ''');
      },
    );
  }

//*********************************************************************CRUD LIGHT */
  // CRUD Operations for Light

// Insert a Light object into the database
  Future<int> insertLight(Light light) async {
    final db = await database;
    return await db.insert('Light', light.toMap());
  }

// Get all Light objects from the database
  Future<List<Light>> getAllLights() async {
    final db = await database;
    final result = await db.query('Light');

    if (result.isEmpty) {
      // Return an empty list if no results are found
      return [];
    }

    // Map the result to a list of Light objects
    return result.map((map) => Light.fromMap(map)).toList();
  }

// Get a specific Light by ID
  Future<Light?> getLightById(int id) async {
    final db = await database;
    final result = await db.query(
      'Light',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      // Return null if the light with the given id is not found
      return null;
    }

    return Light.fromMap(result.first);
  }

// Update a Light object in the database
  Future<int> updateLight(Light light) async {
    final db = await database;
    return await db.update(
      'Light',
      light.toMap(),
      where: 'id = ?',
      whereArgs: [light.id],
    );
  }

// Delete a Light object from the database
  Future<int> deleteLight(int id) async {
    final db = await database;
    return await db.delete(
      'Light',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

//*********************************************************************CRUD STATU */
Future<int> insertStatu(Statu statu) async {
  final db = await database;
  
  // Récupère tous les statuts pour calculer le prochain ID
  final statusList = await getAllStatus();
  int newId = statusList.isEmpty ? 1 : statusList.length + 1;
  
  statu.statuId = newId; // Assigne l'ID calculé

  return await db.insert('Statu', statu.toMap());
}


  Future<List<Statu>> getAllStatus() async {
    final db = await database;
    final maps = await db.query('Statu');
    return maps.map((map) => Statu.fromMap(map)).toList();
  }

  Future<int> updateStatu(Statu statu) async {
    final db = await database;
    return await db.update(
      'Statu',
      statu.toMap(),
      where: 'statu_id = ?',
      whereArgs: [statu.statuId],
    );
  }

  Future<int> deleteStatu(int statuId) async {
    final db = await database;
    return await db.delete(
      'Statu',
      where: 'statu_id = ?',
      whereArgs: [statuId],
    );
  }

  // Méthode pour mettre à jour le délai d'un statut
Future<int> updateStatuDelay(int statuId, int newDelay) async {
  final db = await database;
  return await db.update(
    'Statu',
    {'delay_after': newDelay}, // Met à jour le champ 'delay_after'
    where: 'statu_id = ?', // Condition pour cibler le statut par son ID
    whereArgs: [statuId], // L'ID du statut à mettre à jour
  );
}


  // CRUD pour Tools

  // Ajouter un outil
  Future<int> insertTool(Tools tool) async {
    final db = await database;
    return await db.insert('Tools', tool.toMap());
  }

  // Récupérer tous les outils
  Future<List<Tools>> getAllTools() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Tools');

    return List.generate(maps.length, (i) {
      return Tools.fromMap(maps[i]);
    });
  }

  // Mettre à jour un outil
  Future<int> updateTool(Tools tool) async {
    final db = await database;
    return await db.update(
      'Tools',
      tool.toMap(),
      where: 'tools_id = ?',
      whereArgs: [tool.toolsId],
    );
  }

  // Supprimer un outil
  Future<int> deleteTool(int id) async {
    final db = await database;
    return await db.delete(
      'Tools',
      where: 'tools_id = ?',
      whereArgs: [id],
    );
  }

  // Récupérer un outil par son ID
  Future<Tools?> getToolById(int toolId) async {
    final db = await database;
    final result = await db.query(
      'Tools',
      where: 'tools_id = ?',
      whereArgs: [toolId],
    );

    if (result.isEmpty) {
      // Retourner null si aucun outil n'est trouvé
      return null;
    }

    return Tools.fromMap(result.first);
  }

  // Ajouter un modèle
  Future<int> insertModel(Model model) async {
    final db = await database;
    return await db.insert('Model', model.toMap());
  }

// Récupérer tous les modèles
  Future<List<Model>> getAllModels() async {
    final db = await database;
    final maps = await db.query('Model');
    return maps.map((map) => Model.fromMap(map)).toList();
  }

// Mettre à jour un modèle
  Future<int> updateModel(Model model) async {
    final db = await database;
    return await db.update(
      'Model',
      model.toMap(),
      where: 'model_id = ?',
      whereArgs: [model.modelId],
    );
  }

// Supprimer un modèle
  Future<int> deleteModel(int modelId) async {
    final db = await database;
    return await db.delete(
      'Model',
      where: 'model_id = ?',
      whereArgs: [modelId],
    );
  }

//******************************CRUD USED_LIGHT */

Future<int> insertUsedLight(UsedLight usedLight) async {
  final db = await database;
  return await db.insert('UsedLight', usedLight.toMap());
}


  Future<List<UsedLight>> getAllUsedLights() async {
    final db = await database;
    final maps = await db.query('UsedLight');
    return maps.map((map) => UsedLight.fromMap(map)).toList();
  }

  Future<int> updateUsedLight(UsedLight usedLight) async {
    final db = await database;
    return await db.update(
      'UsedLight',
      usedLight.toMap(),
      where: 'used_light_id = ?',
      whereArgs: [usedLight.usedLightId],
    );
  }

  Future<int> deleteUsedLight(int usedLightId) async {
    final db = await database;
    return await db.delete(
      'UsedLight',
      where: 'used_light_id = ?',
      whereArgs: [usedLightId],
    );
  }
}
