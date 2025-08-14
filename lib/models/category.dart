class Category {
  final int? id;
  final String name;
  final String? imagePath;

  Category({this.id, required this.name, this.imagePath});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_path': imagePath,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      imagePath: map['image_path'] as String?,
    );
  }
} 