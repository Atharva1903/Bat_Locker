import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/category.dart';
import '../widgets/image_picker_widget.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await DatabaseHelper().getCategories();
    setState(() {
      _categories = cats;
      _loading = false;
    });
  }

  void _showCategoryDialog({Category? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    String? imagePath = category?.imagePath;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(category == null ? 'Add Category' : 'Edit Category', style: const TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Category Name', labelStyle: TextStyle(color: Colors.white70)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            ImagePickerWidget(
              initialImagePath: imagePath,
              onImageSelected: (path) => imagePath = path,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              if (category == null) {
                await DatabaseHelper().insertCategory(Category(name: nameController.text, imagePath: imagePath));
              } else {
                await DatabaseHelper().updateCategory(Category(id: category.id, name: nameController.text, imagePath: imagePath));
              }
              Navigator.pop(context);
              _loadCategories();
            },
            child: Text(category == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(int id) async {
    await DatabaseHelper().deleteCategory(id);
    _loadCategories();
  }

  void _showEditCategoryDialog(Category category) {
    final nameController = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Edit Category', style: TextStyle(color: Colors.red)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Rename Category', labelStyle: TextStyle(color: Colors.white70)),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper().deleteCategory(category.id!);
              Navigator.pop(context);
              _loadCategories();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              await DatabaseHelper().updateCategory(Category(id: category.id, name: nameController.text, imagePath: category.imagePath));
              Navigator.pop(context);
              _loadCategories();
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.red[900],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return ListTile(
                  leading: cat.imagePath != null
                      ? Image.asset(cat.imagePath!, width: 40, height: 40, fit: BoxFit.cover)
                      : const Icon(Icons.folder, color: Colors.red),
                  title: Text(cat.name, style: const TextStyle(color: Colors.white)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        onPressed: () => _showEditCategoryDialog(cat),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteCategory(cat.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
} 