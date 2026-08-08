import 'package:flutter_test/flutter_test.dart';
import 'package:my_english_ankier_flutter/models/article.dart';

void main() {
  group('Article Model', () {
    test('should create article with all fields', () {
      final now = DateTime.now();
      final article = Article(
        id: 1,
        title: 'Test Article',
        content: 'Line 1\nLine 2\nLine 3',
        translatedContent: '测试文章',
        createdAt: now,
        updatedAt: now,
      );

      expect(article.id, 1);
      expect(article.title, 'Test Article');
      expect(article.content, 'Line 1\nLine 2\nLine 3');
      expect(article.translatedContent, '测试文章');
      expect(article.createdAt, now);
      expect(article.updatedAt, now);
    });

    test('should create article without translation', () {
      final article = Article(
        title: 'Test Article',
        content: 'Content',
      );

      expect(article.id, null);
      expect(article.translatedContent, null);
      expect(article.createdAt, isNotNull);
      expect(article.updatedAt, isNotNull);
    });

    test('should calculate total lines correctly', () {
      final article = Article(
        title: 'Test',
        content: 'Line 1\nLine 2\nLine 3',
      );

      expect(article.totalLines, 3);
    });

    test('should handle empty content', () {
      final article = Article(
        title: 'Test',
        content: '',
      );

      expect(article.totalLines, 0);
    });

    test('should convert to map correctly', () {
      final now = DateTime(2024, 1, 1, 12, 0, 0);
      final article = Article(
        id: 1,
        title: 'Test',
        content: 'Content',
        translatedContent: '翻译',
        createdAt: now,
        updatedAt: now,
      );

      final map = article.toMap();

      expect(map['id'], 1);
      expect(map['title'], 'Test');
      expect(map['content'], 'Content');
      expect(map['translated_content'], '翻译');
      expect(map['created_at'], now.millisecondsSinceEpoch);
      expect(map['updated_at'], now.millisecondsSinceEpoch);
    });

    test('should create from map correctly', () {
      final now = DateTime(2024, 1, 1, 12, 0, 0);
      final map = {
        'id': 1,
        'title': 'Test',
        'content': 'Content',
        'translated_content': '翻译',
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      };

      final article = Article.fromMap(map);

      expect(article.id, 1);
      expect(article.title, 'Test');
      expect(article.content, 'Content');
      expect(article.translatedContent, '翻译');
      expect(article.createdAt, now);
      expect(article.updatedAt, now);
    });

    test('should copy with new values', () {
      final article = Article(
        id: 1,
        title: 'Original',
        content: 'Content',
      );

      final updated = article.copyWith(title: 'Updated');

      expect(updated.id, 1);
      expect(updated.title, 'Updated');
      expect(updated.content, 'Content');
    });

    test('should return correct string representation', () {
      final article = Article(
        id: 1,
        title: 'Test',
        content: 'Line 1\nLine 2',
      );

      expect(article.toString(), 'Article(id: 1, title: Test, totalLines: 2)');
    });
  });
}