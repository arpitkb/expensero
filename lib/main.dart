import 'package:expensero/auth/auth_state.dart';
import 'package:expensero/screens/pin_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'screens/home_screen.dart';
import 'services/database_helper.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expenses.db');
    developer.log('Database path: $path'); // Print the database path
    await DatabaseHelper.instance.database; // This will initialize the database
    developer.log('Database initialized successfully');
  } catch (e) {
    developer.log('Error initializing database: $e');
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer<AuthState>(
        builder: (context, authState, child) {
          return authState.isAuthenticated
              ? const HomeScreen()
              : const PinEntryScreen();
        },
      ),
    );
  }
}
