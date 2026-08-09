import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:my_english_ankier_flutter/database/database_helper.dart';
import 'package:my_english_ankier_flutter/database/article_dao.dart';
import 'package:my_english_ankier_flutter/database/skill_progress_dao.dart';
import 'package:my_english_ankier_flutter/models/article.dart';
import 'package:my_english_ankier_flutter/models/skill_progress.dart';
import 'package:my_english_ankier_flutter/models/skill_type.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // Clean up database before each test
  setUp(() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('skill_progress');
    await db.delete('articles');
  });

  group('SkillProgressDao', () {
    late SkillProgressDao skillProgressDao;
    late ArticleDao articleDao;
    late int articleId;

    setUp(() async {
      skillProgressDao = SkillProgressDao();
      articleDao = ArticleDao();

      // Create a test article
      final article = Article(
        title: 'Test Article',
        content: 'Line 1\nLine 2\nLine 3',
      );
      articleId = await articleDao.createArticle(article);
    });

    test('should create skill progress', () async {
      final progress = SkillProgress(
        articleId: articleId,
        skillType: 'reading',
        lastLinePosition: 10,
      );

      final id = await skillProgressDao.createSkillProgress(progress);

      expect(id, greaterThan(0));
    });

    test('should get skill progress by article ID and skill type', () async {
      final progress = SkillProgress(
        articleId: articleId,
        skillType: 'reading',
        lastLinePosition: 15,
      );

      await skillProgressDao.createSkillProgress(progress);
      final retrieved = await skillProgressDao.getSkillProgress(articleId, SkillType.reading);

      expect(retrieved, isNotNull);
      expect(retrieved!.lastLinePosition, 15);
    });

    test('should get all skill progress for an article', () async {
      await skillProgressDao.createSkillProgress(
        SkillProgress(articleId: articleId, skillType: 'reading', lastLinePosition: 10),
      );
      await skillProgressDao.createSkillProgress(
        SkillProgress(articleId: articleId, skillType: 'listening', lastLinePosition: 20),
      );

      final progressList = await skillProgressDao.getSkillProgressForArticle(articleId);

      expect(progressList.length, 2);
    });

    test('should update skill progress', () async {
      final progress = SkillProgress(
        articleId: articleId,
        skillType: 'reading',
        lastLinePosition: 10,
      );

      await skillProgressDao.createSkillProgress(progress);
      final retrieved = await skillProgressDao.getSkillProgress(articleId, SkillType.reading);

      final updated = retrieved!.copyWith(lastLinePosition: 25);
      await skillProgressDao.updateSkillProgress(updated);

      final retrievedUpdated = await skillProgressDao.getSkillProgress(articleId, SkillType.reading);
      expect(retrievedUpdated!.lastLinePosition, 25);
    });

    test('should update last line position', () async {
      // Create initial progress
      await skillProgressDao.updateLastLinePosition(articleId, SkillType.reading, 10);

      // Update it
      await skillProgressDao.updateLastLinePosition(articleId, SkillType.reading, 30);

      final retrieved = await skillProgressDao.getSkillProgress(articleId, SkillType.reading);
      expect(retrieved!.lastLinePosition, 30);
    });

    test('should create progress if not exists when updating', () async {
      await skillProgressDao.updateLastLinePosition(articleId, SkillType.writing, 5);

      final retrieved = await skillProgressDao.getSkillProgress(articleId, SkillType.writing);
      expect(retrieved, isNotNull);
      expect(retrieved!.lastLinePosition, 5);
    });

    test('should delete skill progress', () async {
      final progress = SkillProgress(
        articleId: articleId,
        skillType: 'reading',
        lastLinePosition: 10,
      );

      final id = await skillProgressDao.createSkillProgress(progress);
      await skillProgressDao.deleteSkillProgress(id);

      final retrieved = await skillProgressDao.getSkillProgress(articleId, SkillType.reading);
      expect(retrieved, null);
    });

    test('should delete all skill progress for an article', () async {
      await skillProgressDao.createSkillProgress(
        SkillProgress(articleId: articleId, skillType: 'reading', lastLinePosition: 10),
      );
      await skillProgressDao.createSkillProgress(
        SkillProgress(articleId: articleId, skillType: 'listening', lastLinePosition: 20),
      );

      await skillProgressDao.deleteSkillProgressForArticle(articleId);

      final progressList = await skillProgressDao.getSkillProgressForArticle(articleId);
      expect(progressList.length, 0);
    });

    test('should initialize all four skill types for article', () async {
      await skillProgressDao.initializeSkillProgressForArticle(articleId);

      final progressList = await skillProgressDao.getSkillProgressForArticle(articleId);

      expect(progressList.length, 4);

      final skillTypes = progressList.map((p) => p.skillType).toSet();
      expect(skillTypes, containsAll(['listening', 'speaking', 'reading', 'writing']));
    });

    test('should maintain independent progress for each skill', () async {
      await skillProgressDao.updateLastLinePosition(articleId, SkillType.reading, 30);
      await skillProgressDao.updateLastLinePosition(articleId, SkillType.listening, 15);

      final readingProgress = await skillProgressDao.getSkillProgress(articleId, SkillType.reading);
      final listeningProgress = await skillProgressDao.getSkillProgress(articleId, SkillType.listening);

      expect(readingProgress!.lastLinePosition, 30);
      expect(listeningProgress!.lastLinePosition, 15);
    });
  });

  group('Cascade Delete', () {
    late SkillProgressDao skillProgressDao;
    late ArticleDao articleDao;

    setUp(() {
      skillProgressDao = SkillProgressDao();
      articleDao = ArticleDao();
    });

    test('should delete skill progress when article is deleted', () async {
      final article = Article(
        title: 'Test Article',
        content: 'Content',
      );

      final articleId = await articleDao.createArticle(article);

      // Create skill progress
      await skillProgressDao.createSkillProgress(
        SkillProgress(articleId: articleId, skillType: 'reading', lastLinePosition: 10),
      );
      await skillProgressDao.createSkillProgress(
        SkillProgress(articleId: articleId, skillType: 'listening', lastLinePosition: 20),
      );

      // Delete article
      await articleDao.deleteArticle(articleId);

      // Verify skill progress is also deleted
      final progressList = await skillProgressDao.getSkillProgressForArticle(articleId);
      expect(progressList.length, 0);
    });
  });

  group('Progress Calculation', () {
    test('should calculate progress percentage correctly', () async {
      final progress = SkillProgress(
        articleId: 1,
        skillType: 'reading',
        lastLinePosition: 25,
      );

      expect(progress.calculateProgress(50), 0.5);
      expect(progress.calculateProgress(100), 0.25);
    });

    test('should handle edge cases', () async {
      final progress = SkillProgress(
        articleId: 1,
        skillType: 'reading',
        lastLinePosition: 0,
      );

      expect(progress.calculateProgress(0), 0.0);
      expect(progress.calculateProgress(100), 0.0);
    });
  });
}