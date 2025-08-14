import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/category.dart';
import '../main.dart';
import '../models/password_entry.dart';
import '../widgets/image_picker_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Add Category', style: TextStyle(color: Colors.black)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Category Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              await DatabaseHelper().insertCategory(Category(name: nameController.text));
              Navigator.pop(context);
              _loadCategories();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showRenameCategoryDialog(Category category) {
    final nameController = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Rename Category', style: TextStyle(color: Colors.black)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'New Category Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
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

  void _showDeleteCategoryDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Category', style: TextStyle(color: Colors.black)),
        content: const Text('Do you really want to delete this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await DatabaseHelper().deleteCategory(category.id!);
              Navigator.pop(context);
              _loadCategories();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleTheme() {
    final appState = MyApp.of(context);
    if (appState != null) {
      appState.toggleTheme();
    }
  }

  void _openCategoryDetail(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(category: category),
      ),
    ).then((_) => _loadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAccentRed,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'BATLOCKER',
          style: TextStyle(
            fontFamily: 'Impact',
            fontSize: 28,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAccentRed))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _categories.isEmpty
                  ? const Center(child: Text('No categories yet. Tap + to add one.', style: TextStyle(fontSize: 18)))
                  : ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          child: ListTile(
                            leading: cat.imagePath != null
                                ? Image.asset(cat.imagePath!, width: 40, height: 40, fit: BoxFit.cover)
                                : Icon(Icons.folder, color: kAccentRed),
                            title: Text(
                              cat.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                            onTap: () => _openCategoryDetail(cat),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.black),
                                  onPressed: () => _showRenameCategoryDialog(cat),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteCategoryDialog(cat),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 24.0, bottom: 24.0),
          child: FloatingActionButton(
            heroTag: 'addCategoryBtn',
            backgroundColor: Colors.black,
            shape: const CircleBorder(),
            onPressed: _showAddCategoryDialog,
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class CategoryDetailScreen extends StatefulWidget {
  final Category category;
  const CategoryDetailScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<PasswordEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await DatabaseHelper().getPasswordsByCategory(widget.category.id!);
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  void _showAddPasswordDialog() {
    final titleController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Add Password', style: TextStyle(color: Colors.black)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username/Email'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            onPressed: () async {
              if (titleController.text.isEmpty || usernameController.text.isEmpty || passwordController.text.isEmpty) return;
              await DatabaseHelper().insertPassword(
                PasswordEntry(
                  categoryId: widget.category.id!,
                  title: titleController.text,
                  username: usernameController.text,
                  password: passwordController.text,
                  notes: '',
                  imagePath: null,
                ),
              );
              Navigator.pop(context);
              _loadEntries();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditPasswordDialog(PasswordEntry entry) {
    final titleController = TextEditingController(text: entry.title);
    final usernameController = TextEditingController(text: entry.username);
    final passwordController = TextEditingController(text: entry.password);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Edit Password', style: TextStyle(color: Colors.black)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username/Email'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            onPressed: () async {
              if (titleController.text.isEmpty || usernameController.text.isEmpty || passwordController.text.isEmpty) return;
              await DatabaseHelper().updatePassword(
                PasswordEntry(
                  id: entry.id,
                  categoryId: widget.category.id!,
                  title: titleController.text,
                  username: usernameController.text,
                  password: passwordController.text,
                  notes: '',
                  imagePath: null,
                ),
              );
              Navigator.pop(context);
              _loadEntries();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeletePasswordDialog(PasswordEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Password', style: TextStyle(color: Colors.black)),
        content: const Text('Do you really want to delete this password?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await DatabaseHelper().deletePassword(entry.id!);
              Navigator.pop(context);
              _loadEntries();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleTheme() {
    final appState = MyApp.of(context);
    if (appState != null) {
      appState.toggleTheme();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAccentRed,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'BATLOCKER',
          style: TextStyle(
            fontFamily: 'Impact',
            fontSize: 28,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAccentRed))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.name,
                    style: const TextStyle(
                      fontFamily: 'Impact',
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _entries.isEmpty
                        ? const Center(child: Text('No passwords yet. Tap + to add one.', style: TextStyle(fontSize: 18)))
                        : ListView.builder(
                            itemCount: _entries.length,
                            itemBuilder: (context, index) {
                              final entry = _entries[index];
                              return Card(
                                color: Colors.white,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 2,
                                child: ListTile(
                                  leading: const Icon(Icons.vpn_key, color: kAccentRed),
                                  title: Text(
                                    entry.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Username: ${entry.username}', style: const TextStyle(color: Colors.black)),
                                      Text('Password: ${entry.password}', style: const TextStyle(color: Colors.black)),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.black),
                                        onPressed: () => _showEditPasswordDialog(entry),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _showDeletePasswordDialog(entry),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 24.0, bottom: 24.0),
          child: FloatingActionButton(
            heroTag: 'addPasswordBtn',
            backgroundColor: Colors.black,
            shape: const CircleBorder(),
            onPressed: _showAddPasswordDialog,
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// Helper to allow theme mode switching
class MyApp extends InheritedWidget {
  final void Function() toggleTheme;
  const MyApp({Key? key, required this.toggleTheme, required Widget child}) : super(key: key, child: child);
  static MyApp? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<MyApp>();
  @override
  bool updateShouldNotify(MyApp oldWidget) => false;
} 