import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'recipes.db');
    return await openDatabase(
      path,
      version: 2, // Increment the version number
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE recipes(id INTEGER PRIMARY KEY, title TEXT, imageUrl TEXT, protein TEXT, carbs TEXT, fats TEXT, energy TEXT, servingSize TEXT, ingredients TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute('ALTER TABLE recipes ADD COLUMN protein TEXT');
          db.execute('ALTER TABLE recipes ADD COLUMN carbs TEXT');
          db.execute('ALTER TABLE recipes ADD COLUMN fats TEXT');
          db.execute('ALTER TABLE recipes ADD COLUMN energy TEXT');
          db.execute('ALTER TABLE recipes ADD COLUMN servingSize TEXT');
          db.execute('ALTER TABLE recipes ADD COLUMN ingredients TEXT');
        }
      },
    );
  }

  Future<void> insertRecipe(Map<String, dynamic> recipe) async {
    final db = await database;
    await db.insert('recipes', recipe, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getRecipes() async {
    final db = await database;
    return await db.query('recipes');
  }

  Future<Map<String, dynamic>?> getRecipe(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('recipes', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<void> deleteRecipe(int id) async {
    final db = await database;
    await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateRecipeName(int id, String newName) async {
    final db = await database;
    await db.update(
      'recipes',
      {'title': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateRecipe(int id, String title, String protein, String carbs, String fats, String energy, String servingSize, String ingredients) async {
    final db = await database;
    await db.update(
      'recipes',
      {
        'title': title,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'energy': energy,
        'servingSize': servingSize,
        'ingredients': ingredients,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}