import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/password_entry.dart';
import '../widgets/image_picker_widget.dart';
import '../utils/encryption_helper.dart';

class PasswordScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  const PasswordScreen({Key? key, required this.categoryId, required this.categoryName}) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  List<PasswordEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await DatabaseHelper().getPasswordsByCategory(widget.categoryId);
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  void _showPasswordDialog({PasswordEntry? entry}) {
    final titleController = TextEditingController(text: entry?.title ?? '');
    final usernameController = TextEditingController(text: entry?.username ?? '');
    final passwordController = TextEditingController(text: entry == null ? '' : EncryptionHelper.decryptText(entry.password));
    final notesController = TextEditingController(text: entry?.notes ?? '');
    String? imagePath = entry?.imagePath;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(entry == null ? 'Add Password' : 'Edit Password', style: const TextStyle(color: Colors.red)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: Colors.white70)),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username/Email', labelStyle: TextStyle(color: Colors.white70)),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: Colors.white70)),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes', labelStyle: TextStyle(color: Colors.white70)),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              ImagePickerWidget(
                initialImagePath: imagePath,
                onImageSelected: (path) => imagePath = path,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (titleController.text.isEmpty || usernameController.text.isEmpty || passwordController.text.isEmpty) return;
              if (entry == null) {
                await DatabaseHelper().insertPassword(
                  PasswordEntry(
                    categoryId: widget.categoryId,
                    title: titleController.text,
                    username: usernameController.text,
                    password: EncryptionHelper.encryptText(passwordController.text),
                    notes: notesController.text,
                    imagePath: imagePath,
                  ),
                );
              } else {
                await DatabaseHelper().updatePassword(
                  PasswordEntry(
                    id: entry.id,
                    categoryId: widget.categoryId,
                    title: titleController.text,
                    username: usernameController.text,
                    password: EncryptionHelper.encryptText(passwordController.text),
                    notes: notesController.text,
                    imagePath: imagePath,
                  ),
                );
              }
              Navigator.pop(context);
              _loadEntries();
            },
            child: Text(entry == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteEntry(int id) async {
    await DatabaseHelper().deletePassword(id);
    _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.red[900],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return ListTile(
                  leading: entry.imagePath != null
                      ? Image.asset(entry.imagePath!, width: 40, height: 40, fit: BoxFit.cover)
                      : const Icon(Icons.vpn_key, color: Colors.red),
                  title: Text(entry.title, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(entry.username, style: const TextStyle(color: Colors.white70)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        onPressed: () => _showPasswordDialog(entry: entry),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteEntry(entry.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () => _showPasswordDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
} 