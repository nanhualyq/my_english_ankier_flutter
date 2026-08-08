import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:my_english_ankier_flutter/database/database_helper.dart';
import 'package:my_english_ankier_flutter/database/article_dao.dart';
import 'package:my_english_ankier_flutter/models/article.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // Clean up database before each test
  setUp(() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('articles');
    await db.delete('skill_progress');
  });

  group('ArticleDao', () {
    late ArticleDao articleDao;

    setUp(() {
      articleDao = ArticleDao();
    });

    test('should create article and return ID', () async {
      final article = Article(
        title: 'Test Article',
        content: 'Line 1\nLine 2',
      );

      final id = await articleDao.createArticle(article);

      expect(id, greaterThan(0));
    });

    test('should get article by ID', () async {
      final article = Article(
        title: 'Test Article',
        content: 'Content',
      );

      final id = await articleDao.createArticle(article);
      final retrieved = await articleDao.getArticleById(id);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, id);
      expect(retrieved.title, 'Test Article');
      expect(retrieved.content, 'Content');
    });

    test('should return null for non-existent article', () async {
      final retrieved = await articleDao.getArticleById(999);

      expect(retrieved, null);
    });

    test('should get all articles', () async {
      await articleDao.createArticle(Article(title: 'Article 1', content: 'Content 1'));
      await articleDao.createArticle(Article(title: 'Article 2', content: 'Content 2'));

      final articles = await articleDao.getAllArticles();

      expect(articles.length, 2);
    });

    test('should update article', () async {
      final article = Article(
        title: 'Original',
        content: 'Content',
      );

      final id = await articleDao.createArticle(article);
      final retrieved = await articleDao.getArticleById(id);

      final updated = retrieved!.copyWith(title: 'Updated');
      await articleDao.updateArticle(updated);

      final retrievedUpdated = await articleDao.getArticleById(id);
      expect(retrievedUpdated!.title, 'Updated');
    });

    test('should delete article', () async {
      final article = Article(
        title: 'To Delete',
        content: 'Content',
      );

      final id = await articleDao.createArticle(article);
      await articleDao.deleteArticle(id);

      final retrieved = await articleDao.getArticleById(id);
      expect(retrieved, null);
    });

    test('should get article count', () async {
      expect(await articleDao.getArticleCount(), 0);

      await articleDao.createArticle(Article(title: 'Article 1', content: 'Content'));
      expect(await articleDao.getArticleCount(), 1);

      await articleDao.createArticle(Article(title: 'Article 2', content: 'Content'));
      expect(await articleDao.getArticleCount(), 2);
    });

    test('should search articles by title', () async {
      await articleDao.createArticle(Article(title: 'Flutter Guide', content: 'Content'));
      await articleDao.createArticle(Article(title: 'Dart Basics', content: 'Content'));
      await articleDao.createArticle(Article(title: 'Flutter Advanced', content: 'Content'));

      final results = await articleDao.searchArticles('Flutter');

      expect(results.length, 2);
    });

    test('should store and retrieve translated content', () async {
      final article = Article(
        title: 'Test',
        content: 'Hello',
        translatedContent: '你好',
      );

      final id = await articleDao.createArticle(article);
      final retrieved = await articleDao.getArticleById(id);

      expect(retrieved!.translatedContent, '你好');
    });
  });
}