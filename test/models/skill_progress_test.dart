import 'package:flutter_test/flutter_test.dart';
import 'package:my_english_ankier_flutter/models/skill_progress.dart';

void main() {
  group('SkillProgress Model', () {
    test('should create skill progress with all fields', () {
      final progress = SkillProgress(
        id: 1,
        articleId: 10,
        skillType: 'reading',
        lastLinePosition: 25,
      );

      expect(progress.id, 1);
      expect(progress.articleId, 10);
      expect(progress.skillType, 'reading');
      expect(progress.lastLinePosition, 25);
    });

    test('should create skill progress with default lastLinePosition', () {
      final progress = SkillProgress(
        articleId: 10,
        skillType: 'listening',
      );

      expect(progress.lastLinePosition, 0);
    });

    test('should calculate progress percentage correctly', () {
      final progress = SkillProgress(
        articleId: 1,
        skillType: 'reading',
        lastLinePosition: 25,
      );

      expect(progress.calculateProgress(50), 0.5);
      expect(progress.calculateProgress(100), 0.25);
      expect(progress.calculateProgress(25), 1.0);
    });

    test('should handle zero total lines', () {
      final progress = SkillProgress(
        articleId: 1,
        skillType: 'reading',
        lastLinePosition: 10,
      );

      expect(progress.calculateProgress(0), 0.0);
    });

    test('should clamp progress to 1.0 maximum', () {
      final progress = SkillProgress(
        articleId: 1,
        skillType: 'reading',
        lastLinePosition: 100,
      );

      expect(progress.calculateProgress(50), 1.0);
    });

    test('should convert to map correctly', () {
      final progress = SkillProgress(
        id: 1,
        articleId: 10,
        skillType: 'writing',
        lastLinePosition: 30,
      );

      final map = progress.toMap();

      expect(map['id'], 1);
      expect(map['article_id'], 10);
      expect(map['skill_type'], 'writing');
      expect(map['last_line_position'], 30);
    });

    test('should create from map correctly', () {
      final map = {
        'id': 1,
        'article_id': 10,
        'skill_type': 'speaking',
        'last_line_position': 15,
      };

      final progress = SkillProgress.fromMap(map);

      expect(progress.id, 1);
      expect(progress.articleId, 10);
      expect(progress.skillType, 'speaking');
      expect(progress.lastLinePosition, 15);
    });

    test('should handle null last_line_position in map', () {
      final map = {
        'id': 1,
        'article_id': 10,
        'skill_type': 'reading',
        'last_line_position': null,
      };

      final progress = SkillProgress.fromMap(map);

      expect(progress.lastLinePosition, 0);
    });

    test('should copy with new values', () {
      final progress = SkillProgress(
        id: 1,
        articleId: 10,
        skillType: 'reading',
        lastLinePosition: 25,
      );

      final updated = progress.copyWith(lastLinePosition: 50);

      expect(updated.id, 1);
      expect(updated.articleId, 10);
      expect(updated.skillType, 'reading');
      expect(updated.lastLinePosition, 50);
    });

    test('should return correct string representation', () {
      final progress = SkillProgress(
        id: 1,
        articleId: 10,
        skillType: 'reading',
        lastLinePosition: 25,
      );

      expect(
        progress.toString(),
        'SkillProgress(id: 1, articleId: 10, skillType: reading, lastLinePosition: 25)',
      );
    });
  });
}