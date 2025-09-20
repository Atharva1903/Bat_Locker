# BatLocker

BatLocker is a secure, customizable password manager app built with Flutter. It features biometric and master password authentication, category and password management, and image support for a visually appealing experience.

## Features
- Unlock with master password
- Add, update, and delete categories 
- Add, update, and delete password entries 
- All data is stored securely and permanently on your device
- Passwords are encrypted before being saved

## Data Storage
- **Database:** All categories and password entries are stored in a local SQLite database (`sqflite`).
- **Sensitive Data:** Passwords are encrypted using AES before being saved. The master password is stored securely using `flutter_secure_storage`.

## Security
- **Master Password:** Required on first launch and stored securely.
- **Encryption:** All passwords are encrypted at rest.

## Customization
- Add, edit, and delete categories and password entries

---

**Note:**
- All your data stays on your device and is never uploaded anywhere.
- For best security, use a strong master password and enable biometric unlock if available. 
