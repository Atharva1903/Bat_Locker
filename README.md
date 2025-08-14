# BatLocker

BatLocker is a secure, customizable password manager app built with Flutter. It features biometric and master password authentication, category and password management, and image support for a visually appealing experience.

## Features
- Unlock with fingerprint (biometric) or master password
- Add, update, and delete categories (with images/icons)
- Add, update, and delete password entries (with site images)
- All data is stored securely and permanently on your device
- Passwords are encrypted before being saved

## Data Storage
- **Database:** All categories and password entries are stored in a local SQLite database (`sqflite`).
- **Images:** Images are stored as file paths in the database, with the actual files saved in the app's local directory.
- **Sensitive Data:** Passwords are encrypted using AES before being saved. The master password is stored securely using `flutter_secure_storage`.

## Security
- **Biometric Authentication:** Uses your device's fingerprint/face unlock for quick access.
- **Master Password:** Required on first launch and stored securely.
- **Encryption:** All passwords are encrypted at rest.

## Customization
- Add, edit, and delete categories and password entries
- Assign images to categories and password entries for easy identification

---

**Note:**
- All your data stays on your device and is never uploaded anywhere.
- For best security, use a strong master password and enable biometric unlock if available. 