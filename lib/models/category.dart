class Category {
  int? id;
  String name;
  static const int maxNameLength = 20; // Set your desired maximum length here

  Category({this.id, required this.name}) {
    if (!isNameValid()) {
      throw Exception(
          'Category name must not exceed $maxNameLength characters');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  bool isNameValid() {
    return name.length <= maxNameLength;
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
    );
  }
}
