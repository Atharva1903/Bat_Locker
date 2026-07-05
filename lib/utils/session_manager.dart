import 'package:cryptography/cryptography.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  SecretKey? _vaultKey;

  bool get isLocked => _vaultKey == null;

  SecretKey? get vaultKey => _vaultKey;

  void setVaultKey(SecretKey key) {
    _vaultKey = key;
  }

  void clearVaultKey() {
    _vaultKey = null;
  }
}
