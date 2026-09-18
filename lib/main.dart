import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database/seed_data.dart';
import 'screens/home_page.dart';

void main() async {
  // Initialize sqflite for Linux desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Seed database with test data if empty (debug only)
  if (kDebugMode) {
    await SeedData.seedIfEmpty();
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My English Anki',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
