import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../db/database_helper.dart';
import '../models/password_entry.dart';
import '../utils/encryption_helper.dart';
import '../utils/theme.dart';
import '../utils/responsive.dart';

class PasswordScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  const PasswordScreen({super.key, required this.categoryId, required this.categoryName});

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
    final decryptedEntries = <PasswordEntry>[];
    for (final entry in entries) {
      final decryptedTitle = await EncryptionHelper.decryptText(entry.title);
      final decryptedUsername = await EncryptionHelper.decryptText(entry.username);
      final decryptedPassword = await EncryptionHelper.decryptText(entry.password);
      final decryptedNotes = await EncryptionHelper.decryptText(entry.notes ?? '');
      decryptedEntries.add(entry.copyWith(
        title: decryptedTitle.isEmpty ? entry.title : decryptedTitle,
        username: decryptedUsername.isEmpty ? entry.username : decryptedUsername,
        password: decryptedPassword.isEmpty ? entry.password : decryptedPassword,
        notes: decryptedNotes,
      ));
    }
    setState(() {
      _entries = decryptedEntries;
      _loading = false;
    });
  }

  void _showPasswordDialog({PasswordEntry? entry}) {
    final titleController = TextEditingController(text: entry?.title ?? '');
    final usernameController = TextEditingController(text: entry?.username ?? '');
    final passwordController = TextEditingController(text: entry?.password ?? '');
    final notesController = TextEditingController(text: entry?.notes ?? '');
    String? imagePath = entry?.imagePath;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kColorTertiary,
        title: Text(
          entry == null ? 'Add Password' : 'Edit Password',
          style: GoogleFonts.anton(color: kColorPrimary, fontSize: context.sp(22), letterSpacing: 1),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: context.sp(14)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username/Email'),
                style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: context.sp(14)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: context.sp(14)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: context.sp(14)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: context.sp(13))),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || usernameController.text.isEmpty || passwordController.text.isEmpty) return;

              final encryptedTitle = await EncryptionHelper.encryptText(titleController.text);
              final encryptedUsername = await EncryptionHelper.encryptText(usernameController.text);
              final encryptedPassword = await EncryptionHelper.encryptText(passwordController.text);
              final encryptedNotes = await EncryptionHelper.encryptText(notesController.text);

              if (entry == null) {
                await DatabaseHelper().insertPassword(
                  PasswordEntry(
                    categoryId: widget.categoryId,
                    title: encryptedTitle,
                    username: encryptedUsername,
                    password: encryptedPassword,
                    notes: encryptedNotes,
                    imagePath: imagePath,
                  ),
                );
              } else {
                await DatabaseHelper().updatePassword(
                  PasswordEntry(
                    id: entry.id,
                    categoryId: widget.categoryId,
                    title: encryptedTitle,
                    username: encryptedUsername,
                    password: encryptedPassword,
                    notes: encryptedNotes,
                    imagePath: imagePath,
                  ),
                );
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
              _loadEntries();
            },
            child: Text(entry == null ? 'Add' : 'Update', style: TextStyle(fontSize: context.sp(13))),
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
      appBar: AppBar(
        title: const Text('BATLOCKER'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kColorPrimary))
          : ListView.builder(
              itemCount: _entries.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: entry.imagePath != null
                        ? Image.asset(entry.imagePath!, width: 40, height: 40, fit: BoxFit.cover)
                        : const Icon(Icons.vpn_key, color: kColorSecondary),
                    title: Text(
                      entry.title,
                      style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: context.sp(15), fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      entry.username,
                      style: GoogleFonts.jetBrainsMono(color: kColorNeutral, fontSize: context.sp(12)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: kColorNeutral),
                          onPressed: () => _showPasswordDialog(entry: entry),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: kColorPrimary),
                          onPressed: () => _deleteEntry(entry.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kColorSecondary,
        foregroundColor: Colors.black,
        shape: const CircleBorder(),
        onPressed: () => _showPasswordDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}