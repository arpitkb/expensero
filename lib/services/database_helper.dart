import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/account.dart';
import 'dart:developer' as developer;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    developer.log("calling _initDB function");
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      // onUpgrade: _upgradeDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    developer.log("calling _createDB function");
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE categories (
  id $idType,
  name $textType
)
''');

    await db.execute('''
CREATE TABLE accounts (
  id $idType,
  name $textType
)
''');

    await db.execute('''
CREATE TABLE expenses (
  id $idType,
  description $textType,
  amount $realType,
  accountId $integerType,
  categoryId $integerType,
  date $textType,
  FOREIGN KEY (accountId) REFERENCES accounts (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)
''');

    // Insert some default categories and accounts
    await db.insert('categories', {'name': 'Housing'});
    await db.insert('categories', {'name': 'Groceries'});
    await db.insert('categories', {'name': 'Food Order'});
    await db.insert('categories', {'name': 'Public Transport'});

    await db.insert('accounts', {'name': 'Cash'});
    await db.insert('accounts', {'name': 'HDFC'});
    await db.insert('accounts', {'name': 'ICICI'});
    await db.insert('accounts', {'name': 'IXIGO-CC'});
    await db.insert('accounts', {'name': 'ICICI-CC'});
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    developer.log('Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      developer
          .log('Upgrading database from version $oldVersion to $newVersion');
      // Add migration logic here if schema has changed
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const realType = 'REAL NOT NULL';
      const integerType = 'INTEGER NOT NULL';

      await db.execute('''
    CREATE TABLE IF NOT EXISTS categories (
      id $idType,
      name $textType
    )
    ''');

      await db.execute('''
    CREATE TABLE IF NOT EXISTS accounts (
      id $idType,
      name $textType
    )
    ''');

      await db.execute('''
CREATE TABLE IF NOT EXISTS expenses (
  id $idType,
  description $textType,
  amount $realType,
  accountId $integerType,
  categoryId $integerType,
  date $textType,
  FOREIGN KEY (accountId) REFERENCES accounts (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)
''');

      await db.insert('categories', {'name': 'Housing'});
      await db.insert('categories', {'name': 'Groceries'});
      await db.insert('categories', {'name': 'Food Order'});
      await db.insert('categories', {'name': 'Public Transport'});

      await db.insert('accounts', {'name': 'Cash'});
      await db.insert('accounts', {'name': 'HDFC'});
      await db.insert('accounts', {'name': 'ICICI'});
      await db.insert('accounts', {'name': 'IXIGO-CC'});
      await db.insert('accounts', {'name': 'ICICI-CC'});

      developer.log('Database upgraded successfully!');
    }
  }

  // Expense CRUD operations
  Future<int> insertExpense(Expense expense) async {
    final db = await instance.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getExpenses() async {
    final db = await instance.database;
    final maps = await db.query('expenses');
    List<Expense> expenses =
        List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  Future<double> currentWeekExpense() async {
    final db = await instance.database;

    // Calculate the start and end dates of the current week (Monday to Sunday)
    DateTime now = DateTime.now();
    DateTime startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1)); // Monday
    DateTime endOfWeek = startOfWeek.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59)); // Sunday

    developer.log('$startOfWeek and $endOfWeek');

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date >= ? AND date <= ?',
      [startOfWeek.toIso8601String(), endOfWeek.toIso8601String()],
    );

    developer.log('result is $result');

    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as double;
    } else {
      return 0.0;
    }
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await instance.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Category CRUD operations
  Future<int> insertCategory(Category category) async {
    final db = await instance.database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories() async {
    final db = await instance.database;
    final maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> updateCategory(Category category) async {
    final db = await instance.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Account CRUD operations
  Future<int> insertAccount(Account account) async {
    final db = await instance.database;
    return await db.insert('accounts', account.toMap());
  }

  Future<List<Account>> getAccounts() async {
    final db = await instance.database;
    final maps = await db.query('accounts');
    return List.generate(maps.length, (i) => Account.fromMap(maps[i]));
  }

  Future<int> updateAccount(Account account) async {
    final db = await instance.database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await instance.database;
    return await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Additional helper methods
  Future<Category?> getCategoryById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  Future<Account?> getAccountById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Expense>> getExpensesByDateRange(
      DateTime start, DateTime end) async {
    final db = await instance.database;
    final maps = await db.query(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<double> getTotalExpensesByCategory(int categoryId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE categoryId = ?',
      [categoryId],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getTotalExpensesByAccount(int accountId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE accountId = ?',
      [accountId],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
