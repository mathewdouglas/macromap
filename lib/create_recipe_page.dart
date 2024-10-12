import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CreateRecipePage extends StatefulWidget {
  const CreateRecipePage({super.key});

  @override
  _CreateRecipePageState createState() => _CreateRecipePageState();
}

class _CreateRecipePageState extends State<CreateRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatsController = TextEditingController();
  final TextEditingController _energyController = TextEditingController();
  final TextEditingController _servingSizeController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  File? _image;
  final String _placeholderImagePath = 'assets/150.png';

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

  Future<void> _pickImage() async {
  try {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final localImage = await File(pickedFile.path).copy('${directory.path}/$fileName');
      setState(() {
        _image = localImage;
      });
    }
  } catch (e) {
    print('Error picking image: $e');
  }
}

  Future<void> _createRecipe() async {
    if (_formKey.currentState!.validate()) {
      final newRecipe = {
        'title': _titleController.text,
        'imageUrl': _image != null ? _image!.path : _placeholderImagePath,
        'protein': _proteinController.text,
        'carbs': _carbsController.text,
        'fats': _fatsController.text,
        'energy': _energyController.text,
        'servingSize': _servingSizeController.text,
        'ingredients': _ingredientsController.text,
      };
      await DatabaseHelper().insertRecipe(newRecipe);
      Navigator.pop(context, true); // Return to the previous screen and indicate success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _image == null
                    ? Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.add_a_photo, size: 50),
                      )
                    : Image.file(_image!, height: 200, fit: BoxFit.cover),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _proteinController,
                      decoration: const InputDecoration(labelText: 'Protein (g)'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter protein';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _carbsController,
                      decoration: const InputDecoration(labelText: 'Carbs (g)'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter carbs';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _fatsController,
                      decoration: const InputDecoration(labelText: 'Fats (g)'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter fats';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _energyController,
                      decoration: const InputDecoration(labelText: 'Energy (kcal)'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter energy';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _servingSizeController,
                decoration: const InputDecoration(labelText: 'Serving Size'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a serving size';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(labelText: 'Ingredients'),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ingredients';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createRecipe,
                child: const Text('Create Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}