import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/skill_progress_dao.dart';
import '../models/skill_progress.dart';
import '../models/skill_type.dart';

/// Returns the lastLinePosition for a specific (articleId, skillType) pair.
///
/// Usage: `ref.watch(skillProgressProvider((articleId, SkillType.reading)))`
final skillProgressProvider =
    FutureProvider.family<int, (int articleId, SkillType skillType)>((
      ref,
      params,
    ) async {
      final (articleId, skillType) = params;
      final dao = SkillProgressDao();
      final progress = await dao.getSkillProgress(articleId, skillType);
      return progress?.lastLinePosition ?? 0;
    });

/// Returns all skill progress records for a given article.
///
/// Usage: `ref.watch(skillProgressListProvider(articleId))`
final skillProgressListProvider =
    FutureProvider.family<List<SkillProgress>, int>((ref, articleId) async {
      final dao = SkillProgressDao();
      return dao.getSkillProgressForArticle(articleId);
    });
