import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../database/article_dao.dart';

// Articles StateNotifier
class ArticlesNotifier extends StateNotifier<List<Article>> {
  final ArticleDao _articleDao;

  ArticlesNotifier(this._articleDao) : super([]) {
    loadArticles();
  }

  // Load all articles
  Future<void> loadArticles() async {
    final articles = await _articleDao.getAllArticles();
    state = articles;
  }

  // Add new article
  Future<int> addArticle(Article article) async {
    final id = await _articleDao.createArticle(article);
    await loadArticles(); // Refresh list
    return id;
  }

  // Update article
  Future<void> updateArticle(Article article) async {
    await _articleDao.updateArticle(article);
    await loadArticles(); // Refresh list
  }

  // Delete article
  Future<void> deleteArticle(int id) async {
    await _articleDao.deleteArticle(id);
    await loadArticles(); // Refresh list
  }

  // Search articles
  Future<void> searchArticles(String query) async {
    if (query.isEmpty) {
      await loadArticles();
    } else {
      final articles = await _articleDao.searchArticles(query);
      state = articles;
    }
  }
}

// Articles provider
final articlesProvider = StateNotifierProvider<ArticlesNotifier, List<Article>>((ref) {
  final articleDao = ArticleDao();
  return ArticlesNotifier(articleDao);
});

// Article count provider
final articleCountProvider = FutureProvider<int>((ref) async {
  final articleDao = ArticleDao();
  return await articleDao.getArticleCount();
});