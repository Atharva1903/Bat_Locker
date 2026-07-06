import 'package:flutter_test/flutter_test.dart';
import 'package:cryptography/cryptography.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:bat_locker/db/database_helper.dart';
import 'package:bat_locker/models/password_entry.dart';
import 'package:bat_locker/utils/encryption_helper.dart';
import 'package:bat_locker/utils/session_manager.dart';

void main() {
  // Initialize sqflite ffi for local unit tests
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Database Helper & Encryption Integration Tests', () {
    setUp(() async {
      // Clear session
      SessionManager().clearVaultKey();
      // Reset database
      final dbHelper = DatabaseHelper();
      await dbHelper.wipeDatabase();
    });

    test('Insert and Retrieve password entry with decryption', () async {
      // 1. Derive key and set session
      const masterPassword = 'TestPassword123!';
      final salt = EncryptionHelper.generateRandomSalt();
      final key = await EncryptionHelper.deriveKey(masterPassword, salt);
      SessionManager().setVaultKey(key);

      // 2. Encrypt inputs
      const originalTitle = 'Google Account';
      const originalUsername = 'user@gmail.com';
      const originalPassword = 'superSecretPassword!';

      final encryptedTitle = await EncryptionHelper.encryptText(originalTitle);
      final encryptedUsername = await EncryptionHelper.encryptText(originalUsername);
      final encryptedPassword = await EncryptionHelper.encryptText(originalPassword);

      // 3. Insert into Database
      final dbHelper = DatabaseHelper();
      final entry = PasswordEntry(
        categoryId: 1,
        title: encryptedTitle,
        username: encryptedUsername,
        password: encryptedPassword,
        notes: '',
        imagePath: null,
      );

      final insertedId = await dbHelper.insertPassword(entry);
      expect(insertedId, greaterThan(0));

      // 4. Retrieve from Database
      final retrievedEntries = await dbHelper.getPasswordsByCategory(1);
      expect(retrievedEntries.length, 1);

      final retrievedEntry = retrievedEntries.first;
      expect(retrievedEntry.title, encryptedTitle);
      expect(retrievedEntry.password, encryptedPassword);

      // 5. Decrypt retrieved values
      final decryptedTitle = await EncryptionHelper.decryptText(retrievedEntry.title);
      final decryptedUsername = await EncryptionHelper.decryptText(retrievedEntry.username);
      final decryptedPassword = await EncryptionHelper.decryptText(retrievedEntry.password);

      expect(decryptedTitle, originalTitle);
      expect(decryptedUsername, originalUsername);
      expect(decryptedPassword, originalPassword);
    });
  });
}
