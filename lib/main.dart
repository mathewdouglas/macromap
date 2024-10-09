import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'create_recipe_page.dart';
import 'recipe_details_page.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MacroMap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: MyHomePage(title: 'Recipes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _recipes = [];

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _pages = <Widget>[
      GridPage(recipes: _recipes, onRemoveRecipe: _removeRecipe, onEditRecipe: _editRecipe),
      const Center(child: Text('Page 2')),
      const Center(child: Text('Page 3')),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        title: Text(widget.title),
      ),
      body: _selectedIndex == 0 ? GridPage(recipes: _recipes, onRemoveRecipe: _removeRecipe, onEditRecipe: _editRecipe) : _pages[_selectedIndex],
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
            icon: Icon(Icons.pageview),
            label: 'Page 2',
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

  const GridPage({super.key, required this.recipes, required this.onRemoveRecipe, required this.onEditRecipe});

  @override
  Widget build(BuildContext context) {
    // Calculate the height of the card and text dynamically
    final double cardHeight = MediaQuery.of(context).size.width / 2; // Assuming a 1:1 aspect ratio for the card
    const double textHeight = 39.0; // Approximate height for the text
    final double totalHeight = cardHeight + textHeight - 10;
    
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
                        child: recipe['imageUrl'].startsWith('http')
                            ? Image.network(
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
}