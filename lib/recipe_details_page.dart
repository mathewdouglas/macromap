import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'dart:io';

class RecipeDetailsPage extends StatefulWidget {
  final int recipeId;
  final VoidCallback onRemoveRecipe;
  final VoidCallback onEditRecipe;

  const RecipeDetailsPage({super.key, required this.recipeId, required this.onRemoveRecipe, required this.onEditRecipe});

  @override
  _RecipeDetailsPageState createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  late TextEditingController _titleController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;
  late TextEditingController _energyController;
  late TextEditingController _servingSizeController;
  late TextEditingController _ingredientsController;
  Map<String, dynamic>? _recipe;

  @override
  void initState() {
    super.initState();
    _fetchRecipe();
  }

  Future<void> _fetchRecipe() async {
    final recipe = await DatabaseHelper().getRecipe(widget.recipeId);
    if (recipe != null) {
      setState(() {
        _recipe = recipe;
        _titleController = TextEditingController(text: recipe['title']);
        _proteinController = TextEditingController(text: recipe['protein']);
        _carbsController = TextEditingController(text: recipe['carbs']);
        _fatsController = TextEditingController(text: recipe['fats']);
        _energyController = TextEditingController(text: recipe['energy']);
        _servingSizeController = TextEditingController(text: recipe['servingSize']);
        _ingredientsController = TextEditingController(text: recipe['ingredients']);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _energyController.dispose();
    _servingSizeController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Recipe'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Recipe Name'),
                ),
                TextField(
                  controller: _proteinController,
                  decoration: const InputDecoration(labelText: 'Protein (g)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _carbsController,
                  decoration: const InputDecoration(labelText: 'Carbs (g)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _fatsController,
                  decoration: const InputDecoration(labelText: 'Fats (g)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _energyController,
                  decoration: const InputDecoration(labelText: 'Energy (kcal)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _servingSizeController,
                  decoration: const InputDecoration(labelText: 'Serving Size'),
                ),
                TextField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(labelText: 'Ingredients'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final newTitle = _titleController.text;
                final newProtein = _proteinController.text;
                final newCarbs = _carbsController.text;
                final newFats = _fatsController.text;
                final newEnergy = _energyController.text;
                final newServingSize = _servingSizeController.text;
                final newIngredients = _ingredientsController.text;

                if (newTitle.isNotEmpty) {
                  await DatabaseHelper().updateRecipe(
                    widget.recipeId,
                    newTitle,
                    newProtein,
                    newCarbs,
                    newFats,
                    newEnergy,
                    newServingSize,
                    newIngredients,
                  );
                  await _fetchRecipe(); // Fetch the updated recipe
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_recipe == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Recipe Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_recipe!['title']),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Recipe'),
                    content: const Text('Are you sure you want to delete this recipe?'),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                      TextButton(
                        child: const Text('Delete'),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          widget.onRemoveRecipe(); // Call the remove recipe callback
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'recipeImage_${_recipe!['id']}',
              child: _recipe!['imageUrl'].startsWith('assets/')
                  ? Image.asset(
                      _recipe!['imageUrl'], // Recipe image URL
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    )
                  : Image.file(
                      File(_recipe!['imageUrl']), // Local image file path
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _recipe!['title'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Protein: ${_recipe!['protein']}g'),
                  Text('Carbs: ${_recipe!['carbs']}g'),
                  Text('Fats: ${_recipe!['fats']}g'),
                  Text('Energy: ${_recipe!['energy']} kcal'),
                  Text('Serving Size: ${_recipe!['servingSize']}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Ingredients',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_recipe!['ingredients']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}