import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'screens/home_screen.dart';
import 'services/database_helper.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expenses.db');
    print('Database path: $path'); // Print the database path
    await DatabaseHelper.instance.database; // This will initialize the database
    print('Database initialized successfully');
  } catch (e) {
    print('Error initializing database: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expense Manager',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomeScreen(),
    );
  }
}
