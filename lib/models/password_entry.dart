class PasswordEntry {
  final int? id;
  final int categoryId;
  final String title;
  final String username;
  final String password;
  final String? notes;
  final String? imagePath;

  PasswordEntry({
    this.id,
    required this.categoryId,
    required this.title,
    required this.username,
    required this.password,
    this.notes,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'title': title,
      'username': username,
      'password': password,
      'notes': notes,
      'image_path': imagePath,
    };
  }

  factory PasswordEntry.fromMap(Map<String, dynamic> map) {
    return PasswordEntry(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      title: map['title'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      notes: map['notes'] as String?,
      imagePath: map['image_path'] as String?,
    );
  }
} 