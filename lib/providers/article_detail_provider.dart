import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../models/skill_progress.dart';
import '../models/skill_type.dart';
import '../database/article_dao.dart';
import '../database/skill_progress_dao.dart';

// Article detail state
class ArticleDetailState {
  final Article? article;
  final List<SkillProgress> skillProgress;
  final bool isLoading;
  final String? error;

  ArticleDetailState({
    this.article,
    this.skillProgress = const [],
    this.isLoading = false,
    this.error,
  });

  ArticleDetailState copyWith({
    Article? article,
    List<SkillProgress>? skillProgress,
    bool? isLoading,
    String? error,
  }) {
    return ArticleDetailState(
      article: article ?? this.article,
      skillProgress: skillProgress ?? this.skillProgress,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Calculate progress percentage for a skill
  double getProgressPercentage(String skillType) {
    if (article == null) return 0.0;
    
    final progress = skillProgress.firstWhere(
      (p) => p.skillType == skillType,
      orElse: () => SkillProgress(
        articleId: article!.id!,
        skillType: skillType,
        lastLinePosition: 0,
      ),
    );
    
    return progress.calculateProgress(article!.totalLines);
  }
}

// Article detail notifier
class ArticleDetailNotifier extends StateNotifier<ArticleDetailState> {
  final ArticleDao _articleDao;
  final SkillProgressDao _skillProgressDao;

  ArticleDetailNotifier(this._articleDao, this._skillProgressDao)
      : super(ArticleDetailState());

  // Load article by ID
  Future<void> loadArticle(int articleId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final article = await _articleDao.getArticleById(articleId);
      if (article == null) {
        state = state.copyWith(isLoading: false, error: 'Article not found');
        return;
      }

      final skillProgress = await _skillProgressDao.getSkillProgressForArticle(articleId);
      
      state = state.copyWith(
        article: article,
        skillProgress: skillProgress,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Update skill progress
  Future<void> updateSkillProgress(String skillType, int lastLinePosition) async {
    if (state.article == null) return;

    try {
      await _skillProgressDao.updateLastLinePosition(
        state.article!.id!,
        SkillType.values.firstWhere((s) => s.name == skillType),
        lastLinePosition,
      );

      // Reload to get updated progress
      await loadArticle(state.article!.id!);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Article detail provider
final articleDetailProvider = StateNotifierProvider.family<ArticleDetailNotifier, ArticleDetailState, int>((ref, articleId) {
  final articleDao = ArticleDao();
  final skillProgressDao = SkillProgressDao();
  final notifier = ArticleDetailNotifier(articleDao, skillProgressDao);
  
  // Load article when provider is created
  notifier.loadArticle(articleId);
  
  return notifier;
});

// Helper provider to get progress percentage for a specific skill
final skillProgressProvider = Provider.family<double, ({int articleId, String skillType})>((ref, params) {
  final articleDetail = ref.watch(articleDetailProvider(params.articleId));
  return articleDetail.getProgressPercentage(params.skillType);
});