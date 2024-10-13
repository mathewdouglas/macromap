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
      version: 3, // Increment the version number
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE recipes(id INTEGER PRIMARY KEY, title TEXT, imageUrl TEXT, protein TEXT, carbs TEXT, fats TEXT, energy TEXT, servingSize TEXT, ingredients TEXT)',
        );
        await db.execute(
          'CREATE TABLE daily_selected_recipes(id INTEGER PRIMARY KEY AUTOINCREMENT, day TEXT, meal TEXT, recipeId INTEGER, FOREIGN KEY(recipeId) REFERENCES recipes(id))',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute(
            'CREATE TABLE daily_selected_recipes(id INTEGER PRIMARY KEY AUTOINCREMENT, day TEXT, meal TEXT, recipeId INTEGER, FOREIGN KEY(recipeId) REFERENCES recipes(id))',
          );
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

  Future<void> insertSelectedRecipe(String day, String meal, int recipeId) async {
    final db = await database;
    await db.insert(
      'daily_selected_recipes',
      {'day': day, 'meal': meal, 'recipeId': recipeId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, int>> getSelectedRecipes(String day) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_selected_recipes',
      where: 'day = ?',
      whereArgs: [day],
    );

    return { for (var item in maps) item['meal'] as String : item['recipeId'] as int };
  }

  Future<void> deleteSelectedRecipe(String day, String meal) async {
    final db = await database;
    await db.delete(
      'daily_selected_recipes',
      where: 'day = ? AND meal = ?',
      whereArgs: [day, meal],
    );
  }
}