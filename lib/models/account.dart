class Account {
  int? id;
  String name;
  static const int maxNameLength = 15; // Set your desired maximum length here

  Account({this.id, required this.name}) {
    if (!isNameValid()) {
      throw Exception('Account name must not exceed $maxNameLength characters');
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

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
    );
  }
}
