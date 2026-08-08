import 'package:sqflite/sqflite.dart';
import '../models/skill_progress.dart';
import '../models/skill_type.dart';
import 'database_helper.dart';

class SkillProgressDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Create skill progress record
  Future<int> createSkillProgress(SkillProgress skillProgress) async {
    final db = await _databaseHelper.database;
    final map = skillProgress.toMap();
    map.remove('id'); // Remove id for auto-increment
    return await db.insert('skill_progress', map);
  }

  // Get skill progress by article ID and skill type
  Future<SkillProgress?> getSkillProgress(int articleId, SkillType skillType) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'skill_progress',
      where: 'article_id = ? AND skill_type = ?',
      whereArgs: [articleId, skillType.name],
    );

    if (maps.isEmpty) return null;
    return SkillProgress.fromMap(maps.first);
  }

  // Get all skill progress for an article
  Future<List<SkillProgress>> getSkillProgressForArticle(int articleId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'skill_progress',
      where: 'article_id = ?',
      whereArgs: [articleId],
    );

    return maps.map((map) => SkillProgress.fromMap(map)).toList();
  }

  // Update skill progress
  Future<int> updateSkillProgress(SkillProgress skillProgress) async {
    final db = await _databaseHelper.database;
    final map = skillProgress.toMap();

    return await db.update(
      'skill_progress',
      map,
      where: 'id = ?',
      whereArgs: [skillProgress.id],
    );
  }

  // Update last line position for a specific skill
  Future<void> updateLastLinePosition(
    int articleId,
    SkillType skillType,
    int lastLinePosition,
  ) async {
    final existing = await getSkillProgress(articleId, skillType);
    
    if (existing != null) {
      final updated = existing.copyWith(lastLinePosition: lastLinePosition);
      await updateSkillProgress(updated);
    } else {
      // Create new progress record if it doesn't exist
      final newProgress = SkillProgress(
        articleId: articleId,
        skillType: skillType.name,
        lastLinePosition: lastLinePosition,
      );
      await createSkillProgress(newProgress);
    }
  }

  // Delete skill progress
  Future<int> deleteSkillProgress(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'skill_progress',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all skill progress for an article
  Future<int> deleteSkillProgressForArticle(int articleId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'skill_progress',
      where: 'article_id = ?',
      whereArgs: [articleId],
    );
  }

  // Initialize all four skill types for a new article
  Future<void> initializeSkillProgressForArticle(int articleId) async {
    for (final skillType in SkillType.values) {
      final progress = SkillProgress(
        articleId: articleId,
        skillType: skillType.name,
        lastLinePosition: 0,
      );
      await createSkillProgress(progress);
    }
  }
}