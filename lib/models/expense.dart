class Expense {
  int? id;
  String description;
  double amount;
  int? accountId;
  int? categoryId;
  DateTime date;

  Expense({
    this.id,
    required this.description,
    required this.amount,
    this.accountId,
    this.categoryId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'accountId': accountId,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      description: map['description'] as String,
      amount: map['amount'] as double,
      accountId: map['accountId'] as int?,
      categoryId: map['categoryId'] as int?,
      date: DateTime.parse(map['date'] as String),
    );
  }
}
