class PasswordEntry {
  final int? id;
  final int categoryId;
  final String title;
  final String username;
  final String password;
  final String? notes;
  final String? imagePath;
  final bool isFavorite;

  PasswordEntry({
    this.id,
    required this.categoryId,
    required this.title,
    required this.username,
    required this.password,
    this.notes,
    this.imagePath,
    this.isFavorite = false,
  });

  PasswordEntry copyWith({
    int? id,
    int? categoryId,
    String? title,
    String? username,
    String? password,
    String? notes,
    String? imagePath,
    bool? isFavorite,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'title': title,
      'username': username,
      'password': password,
      'notes': notes,
      'image_path': imagePath,
      'is_favorite': isFavorite ? 1 : 0,
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
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
    );
  }
} 