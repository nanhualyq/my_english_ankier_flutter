import 'package:sqflite/sqflite.dart';
import '../models/article.dart';
import 'database_helper.dart';

class ArticleDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Create a new article
  Future<int> createArticle(Article article) async {
    final db = await _databaseHelper.database;
    final map = article.toMap();
    map.remove('id'); // Remove id for auto-increment
    return await db.insert('articles', map);
  }

  // Get article by ID
  Future<Article?> getArticleById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'articles',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Article.fromMap(maps.first);
  }

  // Get all articles
  Future<List<Article>> getAllArticles() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('articles', orderBy: 'updated_at DESC');

    return maps.map((map) => Article.fromMap(map)).toList();
  }

  // Update article
  Future<int> updateArticle(Article article) async {
    final db = await _databaseHelper.database;
    final map = article.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;

    return await db.update(
      'articles',
      map,
      where: 'id = ?',
      whereArgs: [article.id],
    );
  }

  // Delete article and associated skill progress (cascade delete)
  Future<int> deleteArticle(int id) async {
    final db = await _databaseHelper.database;
    
    // Delete associated skill progress first (explicit deletion)
    await db.delete(
      'skill_progress',
      where: 'article_id = ?',
      whereArgs: [id],
    );
    
    // Delete the article
    return await db.delete(
      'articles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get article count
  Future<int> getArticleCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM articles');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Search articles by title
  Future<List<Article>> searchArticles(String query) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'articles',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => Article.fromMap(map)).toList();
  }
}