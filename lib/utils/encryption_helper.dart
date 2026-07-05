import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'session_manager.dart';

class EncryptionHelper {
  static final _algorithm = AesGcm.with256bits();

  // Generate a random 32-byte salt
  static List<int> generateRandomSalt() {
    final random = Random.secure();
    return List<int>.generate(32, (index) => random.nextInt(256));
  }

  // Derive 256-bit AES key using Argon2id
  static Future<SecretKey> deriveKey(String password, List<int> salt) async {
    final argon2id = Argon2id(
      parallelism: 1,
      memory: 15360, // 15 MB
      iterations: 2,
      hashLength: 32, // 32 bytes = 256 bits
    );
    return await argon2id.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  // Encrypt plaintext using GCM with the session key in memory
  static Future<String> encryptText(String plainText) async {
    final key = SessionManager().vaultKey;
    if (key == null) {
      throw Exception('Vault is locked. Encryption key not found in memory.');
    }
    if (plainText.isEmpty) return '';

    final secretBox = await _algorithm.encrypt(
      utf8.encode(plainText),
      secretKey: key,
    );
    return base64.encode(secretBox.concatenation());
  }

  // Decrypt ciphertext using GCM with the session key in memory
  static Future<String> decryptText(String encryptedText) async {
    final key = SessionManager().vaultKey;
    if (key == null) {
      throw Exception('Vault is locked. Decryption key not found in memory.');
    }
    if (encryptedText.isEmpty) return '';

    try {
      final decoded = base64.decode(encryptedText);
      final secretBox = SecretBox.fromConcatenation(
        decoded,
        nonceLength: 12,
        macLength: 16,
      );
      final decryptedBytes = await _algorithm.decrypt(
        secretBox,
        secretKey: key,
      );
      return utf8.decode(decryptedBytes);
    } catch (_) {
      return '';
    }
  }

  // Encrypt plaintext using GCM with a specific temporary key
  static Future<String> encryptWithKey(String plainText, SecretKey key) async {
    if (plainText.isEmpty) return '';
    final secretBox = await _algorithm.encrypt(
      utf8.encode(plainText),
      secretKey: key,
    );
    return base64.encode(secretBox.concatenation());
  }

  // Decrypt ciphertext using GCM with a specific temporary key
  static Future<String> decryptWithKey(String encryptedText, SecretKey key) async {
    if (encryptedText.isEmpty) return '';
    try {
      final decoded = base64.decode(encryptedText);
      final secretBox = SecretBox.fromConcatenation(
        decoded,
        nonceLength: 12,
        macLength: 16,
      );
      final decryptedBytes = await _algorithm.decrypt(
        secretBox,
        secretKey: key,
      );
      return utf8.decode(decryptedBytes);
    } catch (_) {
      return '';
    }
  }

  static final legacyIv = encrypt_lib.IV.fromLength(16);

  // Legacy Decryption helper using AES-128 in CBC mode (for database migration only)
  static String decryptLegacy(String cipherText) {
    if (cipherText.isEmpty) return '';
    try {
      final key = encrypt_lib.Key.fromUtf8('batlockerbatlocke'.substring(0, 16));
      final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(key));
      return encrypter.decrypt64(cipherText, iv: legacyIv);
    } catch (_) {
      return '';
    }
  }
}