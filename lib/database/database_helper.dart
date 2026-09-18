import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('english_learner.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final localAppData = Platform.environment['LOCALAPPDATA'] ?? '.';

    // Use separate directories for debug and release
    final appName = kDebugMode ? 'my_english_ankier_flutter_dev' : 'my_english_ankier_flutter';
    final appDir = join(localAppData, appName);

    // Create directory if it doesn't exist
    await Directory(appDir).create(recursive: true);

    final path = join(appDir, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create articles table
    await db.execute('''
      CREATE TABLE articles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        translated_content TEXT,
        url TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create skill_progress table
    await db.execute('''
      CREATE TABLE skill_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        article_id INTEGER NOT NULL,
        skill_type TEXT NOT NULL,
        last_line_position INTEGER DEFAULT 0,
        UNIQUE(article_id, skill_type),
        FOREIGN KEY (article_id) REFERENCES articles(id) ON DELETE CASCADE
      )
    ''');

    // Enable foreign key support
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations
    if (oldVersion < 2) {
      // Add url column to articles table
      await db.execute('ALTER TABLE articles ADD COLUMN url TEXT');
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}