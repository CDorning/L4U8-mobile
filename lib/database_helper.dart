import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'recycling.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE districts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE recycling_rules(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        district_id INTEGER,
        material_name TEXT NOT NULL,
        is_recyclable INTEGER NOT NULL,
        FOREIGN KEY (district_id) REFERENCES districts (id)
      )
    ''');
    
    // Populate with initial data
    await _populateData(db);
  }

  Future<void> _populateData(Database db) async {
    final data = {
      'Erean': {'Glass': 1, 'Metal': 1, 'Paper / Carboard': 1, 'Plastic (PET/E)': 1, 'Plastic (PVC)': 0, 'Plastic (HDPE)': 1, 'Plastic (PP)': 1, 'Small Household Electricals': 1, 'Garden Waste': 1},
      'Zord': {'Glass': 1, 'Metal': 1, 'Paper / Carboard': 1, 'Plastic (PET/E)': 1, 'Plastic (PVC)': 1, 'Plastic (HDPE)': 1, 'Plastic (PP)': 1, 'Small Household Electricals': 0, 'Garden Waste': 1},
      'Brunad': {'Glass': 1, 'Metal': 1, 'Paper / Carboard': 1, 'Plastic (PET/E)': 1, 'Plastic (PVC)': 0, 'Plastic (HDPE)': 1, 'Plastic (PP)': 0, 'Small Household Electricals': 0, 'Garden Waste': 1},
      'Yaean': {'Glass': 1, 'Metal': 1, 'Paper / Carboard': 1, 'Plastic (PET/E)': 1, 'Plastic (PVC)': 1, 'Plastic (HDPE)': 1, 'Plastic (PP)': 1, 'Small Household Electricals': 0, 'Garden Waste': 1},
      'Bylyn': {'Glass': 1, 'Metal': 1, 'Paper / Carboard': 1, 'Plastic (PET/E)': 0, 'Plastic (PVC)': 0, 'Plastic (HDPE)': 1, 'Plastic (PP)': 0, 'Small Household Electricals': 0, 'Garden Waste': 1},
      'Frestin': {'Glass': 1, 'Metal': 1, 'Paper / Carboard': 1, 'Plastic (PET/E)': 1, 'Plastic (PVC)': 1, 'Plastic (HDPE)': 1, 'Plastic (PP)': 1, 'Small Household Electricals': 0, 'Garden Waste': 1},
      'Docia': {'Glass': 1, 'Metal': 1, 'Paper / Carboard': 1, 'Plastic (PET/E)': 1, 'Plastic (PVC)': 1, 'Plastic (HDPE)': 1, 'Plastic (PP)': 0, 'Small Household Electricals': 1, 'Garden Waste': 1},
      'Stonyam': {'Glass': 1, 'Metal': 1, 'Paper / Carboard': 1, 'Plastic (PET/E)': 1, 'Plastic (PVC)': 0, 'Plastic (HDPE)': 1, 'Plastic (PP)': 0, 'Small Household Electricals': 0, 'Garden Waste': 1},
      'Marend': {'Glass': 1, 'Metal': 1, 'Paper / Carboard': 1, 'Plastic (PET/E)': 1, 'Plastic (PVC)': 0, 'Plastic (HDPE)': 1, 'Plastic (PP)': 1, 'Small Household Electricals': 1, 'Garden Waste': 1},
      'Ryall': {'Glass': 1, 'Metal': 1, 'Paper / Carboard': 1, 'Plastic (PET/E)': 1, 'Plastic (PVC)': 1, 'Plastic (HDPE)': 1, 'Plastic (PP)': 0, 'Small Household Electricals': 0, 'Garden Waste': 1},
      'Pryn': {'Glass': 1, 'Metal': 1, 'Paper / Carboard': 1, 'Plastic (PET/E)': 1, 'Plastic (PVC)': 0, 'Plastic (HDPE)': 1, 'Plastic (PP)': 1, 'Small Household Electricals': 1, 'Garden Waste': 1},
      'Ruril': {'Glass': 1, 'Metal': 1, 'Paper / Carboard': 1, 'Plastic (PET/E)': 1, 'Plastic (PVC)': 1, 'Plastic (HDPE)': 1, 'Plastic (PP)': 0, 'Small Household Electricals': 0, 'Garden Waste': 1}
    };

    final batch = db.batch();
    for (var districtName in data.keys) {
      batch.insert('districts', {'name': districtName});
    }
    await batch.commit(noResult: true);
    
    final batch2 = db.batch();
    List<Map> districts = await db.query('districts');
    for (var district in districts) {
        final districtId = district['id'];
        final districtName = district['name'];
        final rules = data[districtName]!;

        for (var material in rules.keys) {
            batch2.insert('recycling_rules', {
                'district_id': districtId,
                'material_name': material,
                'is_recyclable': rules[material]
            });
        }
    }
     await batch2.commit(noResult: true);
  }

  // ESSENTIAL FEATURE 1: Search by district
  Future<List<Map<String, dynamic>>> getRulesForDistrict(String districtName) async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT T2.material_name, T2.is_recyclable
      FROM districts T1
      JOIN recycling_rules T2 ON T1.id = T2.district_id
      WHERE T1.name = ?
    ''', [districtName]);
  }

  // ESSENTIAL FEATURE 2: Search by material
  Future<List<Map<String, dynamic>>> getDistrictsForMaterial(String materialName) async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT T1.name
      FROM districts T1
      JOIN recycling_rules T2 ON T1.id = T2.district_id
      WHERE T2.material_name = ? AND T2.is_recyclable = 1
    ''', [materialName]);
  }

  // Helper to get all district names for search
  Future<List<String>> getAllDistricts() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('districts');
    return List.generate(maps.length, (i) => maps[i]['name'] as String);
  }

  // Helper to get all material names for search
  Future<List<String>> getAllMaterials() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT DISTINCT material_name FROM recycling_rules');
    return List.generate(maps.length, (i) => maps[i]['material_name'] as String);
  }

  // DISTINCTION FEATURE: Delete a recycling rule
  Future<void> deleteRule(String districtName, String materialName) async {
    Database db = await instance.database;
    // In a real app, this would be a more robust update, e.g., setting is_recyclable to 0.
    // For this prototype, a simple delete demonstrates the gesture working.
    await db.rawDelete('''
      DELETE FROM recycling_rules
      WHERE material_name = ? AND district_id = (SELECT id FROM districts WHERE name = ?)
    ''', [materialName, districtName]);
  }
}