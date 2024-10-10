import 'package:flutter/material.dart';

class RecipeSelectionPage extends StatefulWidget {
  final List<Map<String, dynamic>> recipes;

  const RecipeSelectionPage({super.key, required this.recipes});

  @override
  _RecipeSelectionPageState createState() => _RecipeSelectionPageState();
}

class _RecipeSelectionPageState extends State<RecipeSelectionPage> {
  List<Map<String, dynamic>> filteredRecipes = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredRecipes = widget.recipes;
  }

  void _filterRecipes(String query) {
    setState(() {
      filteredRecipes = widget.recipes
          .where((recipe) =>
              recipe['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterRecipes,
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: filteredRecipes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredRecipes[index]['title']),
                    onTap: () {
                      Navigator.of(context).pop(filteredRecipes[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}