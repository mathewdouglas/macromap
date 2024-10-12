import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'create_recipe_page.dart';
import 'recipe_details_page.dart';
import 'weekly_plan_page.dart';
import 'dart:io';

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool isGridView = true;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Map<String, dynamic>> _recipes = [];

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _pages = <Widget>[
      GridPage(recipes: _recipes, onRemoveRecipe: _removeRecipe, onEditRecipe: _editRecipe, isGridView: isGridView),
      WeeklyPlanPage(),
      const Center(child: Text('Page 3')),
    ];
  }

  Future<void> _addRecipe() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateRecipePage()),
    );
    if (result == true) {
      _loadRecipes();
    }
  }

  Future<void> _loadRecipes() async {
    final recipes = await DatabaseHelper().getRecipes();
    if (mounted) {
      setState(() {
        _recipes = recipes;
      });
    }
  }

  Future<void> _removeRecipe(int id) async {
    await DatabaseHelper().deleteRecipe(id);
    _loadRecipes();
    Navigator.pop(context); // Go back to the previous screen after deletion
  }

  Future<void> _editRecipe() async {
    _loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MacroMap", style: TextStyle(fontWeight: FontWeight.bold),),
        actions: _selectedIndex == 0
      ? [
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Search functionality to be added later
            },
          ),
        ]
      : null,
      ),
      body: _selectedIndex == 0
                ? GridPage(
                    recipes: _recipes,
                    onRemoveRecipe: _removeRecipe,
                    onEditRecipe: _editRecipe,
                    isGridView: isGridView,
                  )
                : _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _addRecipe,
              tooltip: 'Create Recipe',
              backgroundColor: Colors.grey,
              child: const Icon(Icons.add, color: Colors.white,),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Weekly Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pages),
            label: 'Page 3',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class GridPage extends StatelessWidget {
  final List<Map<String, dynamic>> recipes;
  final Function(int) onRemoveRecipe;
  final VoidCallback onEditRecipe;
  final bool isGridView;

  const GridPage({
    super.key,
    required this.recipes,
    required this.onRemoveRecipe,
    required this.onEditRecipe,
    required this.isGridView,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the height of the card and text dynamically
    final double cardHeight = MediaQuery.of(context).size.width / 2; // Assuming a 1:1 aspect ratio for the card
    const double textHeight = 39.0; // Approximate height for the text
    final double totalHeight = cardHeight + textHeight - 10;

    return isGridView ? buildGridView(totalHeight) : buildListView();
  }
    
  Widget buildGridView(double totalHeight) {
    return Padding(
      padding: const EdgeInsets.all(10.0), // Add padding around the grid
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 0,
          mainAxisExtent: totalHeight,
        ),
        itemCount: recipes.length, // Number of items in the grid
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailsPage(
                    recipeId: recipe['id'],
                    onRemoveRecipe: () => onRemoveRecipe(recipe['id']),
                    onEditRecipe: onEditRecipe,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Hero(
                    tag: 'recipeImage_${recipe['id']}',
                    child: Container(
                      child: AspectRatio(
                        aspectRatio: 1.0, // Set aspect ratio to 1:1
                        child: recipe['imageUrl'].startsWith('assets/')
                            ? Image.asset(
                                recipe['imageUrl'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : Image.file(
                                File(recipe['imageUrl']),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                      ),
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      recipe['title'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left, // Align text to the left
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildListView() {
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailsPage(
                  recipeId: recipe['id'],
                  onRemoveRecipe: () => onRemoveRecipe(recipe['id']),
                  onEditRecipe: onEditRecipe,
                ),
              ),
            );
          },
          child: ListTile(
            leading: Hero(
              tag: 'recipeImage_${recipe['id']}',
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2.0), // Add border
                ),
                child: recipe['imageUrl'].startsWith('assets/')
                    ? Image.asset(
                        recipe['imageUrl'],
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(recipe['imageUrl']),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            title: Text(
              recipe['title'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}