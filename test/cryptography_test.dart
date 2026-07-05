import 'package:flutter_test/flutter_test.dart';
import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:bat_locker/utils/encryption_helper.dart';
import 'package:bat_locker/utils/session_manager.dart';

void main() {
  group('Zero-Knowledge Cryptography Tests', () {
    test('Key Derivation and AES-256-GCM Encryption/Decryption', () async {
      const password = 'TestMasterPassword123!';
      final salt = EncryptionHelper.generateRandomSalt();

      expect(salt.length, 32);

      // Derive Key
      final key = await EncryptionHelper.deriveKey(password, salt);
      expect(key, isA<SecretKey>());

      // Set key in session
      SessionManager().setVaultKey(key);
      expect(SessionManager().isLocked, isFalse);

      const originalText = 'my_super_secret_password_99';

      // Encrypt
      final ciphertext = await EncryptionHelper.encryptText(originalText);
      expect(ciphertext, isNotEmpty);
      expect(ciphertext, isNot(equals(originalText)));

      // Decrypt
      final decryptedText = await EncryptionHelper.decryptText(ciphertext);
      expect(decryptedText, equals(originalText));

      // Clear Session
      SessionManager().clearVaultKey();
      expect(SessionManager().isLocked, isTrue);
    });

    test('Legacy Decryption Backwards Compatibility', () {
      const plaintext = 'my_legacy_password_123';
      final key = encrypt_lib.Key.fromUtf8('batlockerbatlocke'.substring(0, 16));
      final iv = EncryptionHelper.legacyIv;
      final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(key));
      final encrypted = encrypter.encrypt(plaintext, iv: iv);


      final decrypted = EncryptionHelper.decryptLegacy(encrypted.base64);
      expect(decrypted, equals(plaintext));
    });
  });
}
