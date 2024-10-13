import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'recipe_selection_page.dart';

class WeeklyPlanPage extends StatefulWidget {
  const WeeklyPlanPage({super.key});

  @override
  _WeeklyPlanPageState createState() => _WeeklyPlanPageState();
}

class _WeeklyPlanPageState extends State<WeeklyPlanPage> {
  late String selectedDay;
  List<Map<String, dynamic>> _recipes = [];
  Map<String, String> selectedRecipes = {
    'Breakfast': 'Select a recipe',
    'Snack 1': 'Select a recipe',
    'Lunch': 'Select a recipe',
    'Snack 2': 'Select a recipe',
    'Dinner': 'Select a recipe',
    'Extra': 'Select a recipe',
  };

  @override
  void initState() {
    super.initState();
    selectedDay = DateFormat('EEE, d MMM yyyy').format(DateTime.now());
    _loadRecipes();
    _loadSelectedRecipes();
  }

  Future<void> _loadRecipes() async {
    final recipes = await DatabaseHelper().getRecipes();
    setState(() {
      _recipes = recipes;
    });
  }

  Future<void> _loadSelectedRecipes() async {
    if (_recipes.isEmpty) {
      await _loadRecipes();
    }
    
    final selectedRecipesMap = await DatabaseHelper().getSelectedRecipes(selectedDay);
    setState(() {
      selectedRecipes = {
        'Breakfast': selectedRecipesMap['Breakfast'] != null ? _recipes.firstWhere((recipe) => recipe['id'] == selectedRecipesMap['Breakfast'])['title'] : 'Select a recipe',
        'Snack 1': selectedRecipesMap['Snack 1'] != null ? _recipes.firstWhere((recipe) => recipe['id'] == selectedRecipesMap['Snack 1'])['title'] : 'Select a recipe',
        'Lunch': selectedRecipesMap['Lunch'] != null ? _recipes.firstWhere((recipe) => recipe['id'] == selectedRecipesMap['Lunch'])['title'] : 'Select a recipe',
        'Snack 2': selectedRecipesMap['Snack 2'] != null ? _recipes.firstWhere((recipe) => recipe['id'] == selectedRecipesMap['Snack 2'])['title'] : 'Select a recipe',
        'Dinner': selectedRecipesMap['Dinner'] != null ? _recipes.firstWhere((recipe) => recipe['id'] == selectedRecipesMap['Dinner'])['title'] : 'Select a recipe',
        'Extra': selectedRecipesMap['Extra'] != null ? _recipes.firstWhere((recipe) => recipe['id'] == selectedRecipesMap['Extra'])['title'] : 'Select a recipe',
      };
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        selectedDay = DateFormat('EEE, d MMM yyyy').format(picked);
      });
      await _loadSelectedRecipes();
    }
  }

  void _selectRecipe(BuildContext context, String meal) async {
    // Navigate to the recipe selection page and get the selected recipe
    final selectedRecipe = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeSelectionPage(recipes: _recipes),
      ),
    );

    if (selectedRecipe != null) {
      final recipeId = _recipes.firstWhere((recipe) => recipe['title'] == selectedRecipe)['id'];
      await DatabaseHelper().insertSelectedRecipe(selectedDay, meal, recipeId);
      setState(() {
        selectedRecipes[meal] = selectedRecipe;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: Text(
                  selectedDay,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                children: [
                  _buildMealCard(context, 'Breakfast'),
                  _buildMealCard(context, 'Snack 1'),
                  _buildMealCard(context, 'Lunch'),
                  _buildMealCard(context, 'Snack 2'),
                  _buildMealCard(context, 'Dinner'),
                  _buildMealCard(context, 'Extra'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, String meal) {
    final selectedRecipe = selectedRecipes[meal] ?? 'Select a recipe';
    return Card(
      child: ListTile(
        title: Text(meal),
        subtitle: Text(selectedRecipe),
        trailing: Icon(Icons.arrow_forward),
        onTap: () => _selectRecipe(context, meal),
      ),
    );
  }

  void _showRecipeSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RecipeSelectionPage(recipes: _recipes);
      },
    );
  }
}