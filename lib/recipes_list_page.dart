import 'package:flutter/material.dart';
import 'dart:io';
import 'recipe_details_page.dart';

class GridPage extends StatefulWidget {
  final List<Map<String, dynamic>> recipes;
  final Function(int) onRemoveRecipe;
  final VoidCallback onEditRecipe;

  const GridPage({super.key, required this.recipes, required this.onRemoveRecipe, required this.onEditRecipe});

  @override
  _GridPageState createState() => _GridPageState();
}

class _GridPageState extends State<GridPage> {
  bool isGridView = true;

  @override
  Widget build(BuildContext context) {
    // Calculate the height of the card and text dynamically
    final double cardHeight = MediaQuery.of(context).size.width / 2; // Assuming a 1:1 aspect ratio for the card
    const double textHeight = 39.0; // Approximate height for the text
    final double totalHeight = cardHeight + textHeight - 10;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality to be added later
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0), // Add padding around the grid
        child: isGridView ? buildGridView(totalHeight) : buildListView(),
      ),
    );
  }

  Widget buildGridView(double totalHeight) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 0,
        mainAxisExtent: totalHeight,
      ),
      itemCount: widget.recipes.length, // Number of items in the grid
      itemBuilder: (context, index) {
        final recipe = widget.recipes[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailsPage(
                  recipeId: recipe['id'],
                  onRemoveRecipe: () => widget.onRemoveRecipe(recipe['id']),
                  onEditRecipe: widget.onEditRecipe,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
            children: [
              Card(
                clipBehavior: Clip.antiAlias,
                child: Hero(
                  tag: 'recipeImage_${recipe['id']}',
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2.0), // Add border
                    ),
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
    );
  }

  Widget buildListView() {
    return ListView.builder(
      itemCount: widget.recipes.length,
      itemBuilder: (context, index) {
        final recipe = widget.recipes[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailsPage(
                  recipeId: recipe['id'],
                  onRemoveRecipe: () => widget.onRemoveRecipe(recipe['id']),
                  onEditRecipe: widget.onEditRecipe,
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
                child: recipe['imageUrl'].startsWith('http')
                    ? Image.network(
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