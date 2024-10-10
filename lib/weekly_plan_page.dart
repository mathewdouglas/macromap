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

  @override
  void initState() {
    super.initState();
    selectedDay = DateFormat('EEE, d MMM yyyy').format(DateTime.now());
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final recipes = await DatabaseHelper().getRecipes();
    setState(() {
      _recipes = recipes;
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                meal,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.left,
              ),
              ElevatedButton(
                onPressed: () async {
                  final selectedRecipe = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeSelectionPage(recipes: _recipes),
                    ),
                  );
                  if (selectedRecipe != null) {
                    // Handle the selected recipe
                    print('Selected Recipe: ${selectedRecipe['name']}');
                  }
                },
                child: Text('Select Recipe'),
              ),
            ],
          ),
        ),
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