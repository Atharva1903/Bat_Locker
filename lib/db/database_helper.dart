import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/password_entry.dart';
import '../models/note.dart';
import '../utils/encryption_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'batlocker.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        image_path TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE passwords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        title TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        notes TEXT,
        image_path TEXT,
        is_favorite INTEGER DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');
    await _createNotesTable(db);
    await _createVaultMetadataTable(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createNotesTable(db);
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE passwords ADD COLUMN is_favorite INTEGER DEFAULT 0');
    }
    if (oldVersion < 4) {
      await _createVaultMetadataTable(db);
    }
  }

  Future<void> _createNotesTable(Database db) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createVaultMetadataTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vault_metadata (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        salt TEXT NOT NULL,
        verification_box TEXT NOT NULL
      )
    ''');
  }

  // Vault Metadata helpers
  Future<void> saveVaultMetadata(String saltBase64, String verificationBoxBase64) async {
    final db = await database;
    await db.delete('vault_metadata');
    await db.insert('vault_metadata', {
      'salt': saltBase64,
      'verification_box': verificationBoxBase64,
    });
  }

  Future<Map<String, String>?> getVaultMetadata() async {
    final db = await database;
    final maps = await db.query('vault_metadata');
    if (maps.isEmpty) return null;
    return {
      'salt': maps.first['salt'] as String,
      'verification_box': maps.first['verification_box'] as String,
    };
  }

  Future<bool> hasVaultMetadata() async {
    final db = await database;
    final maps = await db.query('vault_metadata');
    return maps.isNotEmpty;
  }

  // Zero-Knowledge Database Migration
  Future<void> migrateToZeroKnowledge(String masterPassword, SecretKey newKey, List<int> newSalt) async {
    final db = await database;

    // 1. Save new metadata
    final String verificationBox = await EncryptionHelper.encryptWithKey('batlocker_vault_verified', newKey);
    await saveVaultMetadata(base64.encode(newSalt), verificationBox);

    // 2. Migrate Passwords
    final passwordsMap = await db.query('passwords');
    for (final map in passwordsMap) {
      final id = map['id'] as int;
      final legacyEncryptedPassword = map['password'] as String;
      final plainTitle = map['title'] as String;
      final plainUsername = map['username'] as String;
      final plainNotes = map['notes'] as String? ?? '';

      // Decrypt legacy password using the hardcoded key (or fall back to plaintext)
      String plainPassword = EncryptionHelper.decryptLegacy(legacyEncryptedPassword);
      if (plainPassword.isEmpty && legacyEncryptedPassword.isNotEmpty) {
        plainPassword = legacyEncryptedPassword;
      }

      // Encrypt all fields using new Dynamic AES-256-GCM Key
      final encryptedTitle = await EncryptionHelper.encryptWithKey(plainTitle, newKey);
      final encryptedUsername = await EncryptionHelper.encryptWithKey(plainUsername, newKey);
      final encryptedPassword = await EncryptionHelper.encryptWithKey(plainPassword, newKey);
      final encryptedNotes = await EncryptionHelper.encryptWithKey(plainNotes, newKey);

      await db.update('passwords', {
        'title': encryptedTitle,
        'username': encryptedUsername,
        'password': encryptedPassword,
        'notes': encryptedNotes,
      }, where: 'id = ?', whereArgs: [id]);
    }

    // 3. Migrate Secure Notes
    final notesMap = await db.query('notes');
    for (final map in notesMap) {
      final id = map['id'] as int;
      final plainTitle = map['title'] as String;
      final plainContent = map['content'] as String;

      // Encrypt fields
      final encryptedTitle = await EncryptionHelper.encryptWithKey(plainTitle, newKey);
      final encryptedContent = await EncryptionHelper.encryptWithKey(plainContent, newKey);

      await db.update('notes', {
        'title': encryptedTitle,
        'content': encryptedContent,
      }, where: 'id = ?', whereArgs: [id]);
    }
  }

  // Category CRUD
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories');
    return maps.map((e) => Category.fromMap(e)).toList();
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update('categories', category.toMap(), where: 'id = ?', whereArgs: [category.id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // PasswordEntry CRUD
  Future<int> insertPassword(PasswordEntry entry) async {
    final db = await database;
    return await db.insert('passwords', entry.toMap());
  }

  Future<List<PasswordEntry>> getPasswordsByCategory(int categoryId) async {
    final db = await database;
    final maps = await db.query('passwords', where: 'category_id = ?', whereArgs: [categoryId]);
    return maps.map((e) => PasswordEntry.fromMap(e)).toList();
  }

  Future<int> updatePassword(PasswordEntry entry) async {
    final db = await database;
    return await db.update('passwords', entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<int> deletePassword(int id) async {
    final db = await database;
    return await db.delete('passwords', where: 'id = ?', whereArgs: [id]);
  }

  // Notes CRUD
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final maps = await db.query('notes', orderBy: 'id DESC');
    return maps.map((e) => Note.fromMap(e)).toList();
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> wipeDatabase() async {
    final db = await database;
    await db.delete('categories');
    await db.delete('passwords');
    await db.delete('notes');
    await db.delete('vault_metadata');
  }

  Future<List<PasswordEntry>> getFavoritePasswords() async {
    final db = await database;
    final maps = await db.query('passwords', where: 'is_favorite = 1');
    return maps.map((e) => PasswordEntry.fromMap(e)).toList();
  }

  Future<int> toggleFavoritePassword(int id, bool isFavorite) async {
    final db = await database;
    return await db.update('passwords', {'is_favorite': isFavorite ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }
}