import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../providers/articles_provider.dart';
import '../database/skill_progress_dao.dart';
import '../widgets/article_card.dart';
import 'article_edit_page.dart';
import 'listening_practice_page.dart';
import 'reading_practice_page.dart';
import 'speaking_practice_page.dart';
import 'writing_practice_page.dart';

/// Homepage displaying the list of English articles with CRUD operations.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(articlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 My English Articles'),
      ),
      body: articles.isEmpty
          ? _buildEmptyState(context, ref)
          : _buildArticleList(context, ref, articles),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addArticle(context, ref),
        tooltip: 'Add Article',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Articles Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + at the bottom right to add your first article',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleList(
    BuildContext context,
    WidgetRef ref,
    List<Article> articles,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return ArticleCard(
          article: article,
          onEdit: () => _editArticle(context, article),
          onSaveAs: () => _saveAsArticle(context, ref, article),
          onResetProgress: () => _resetProgress(context, ref, article),
          onDelete: () => _deleteArticle(context, ref, article),
          onListeningPractice: () => _openListeningPractice(context, article),
          onSpeakingPractice: () => _openSpeakingPractice(context, article),
          onReadingPractice: () => _openReadingPractice(context, article),
          onWritingPractice: () => _openWritingPractice(context, article),
        );
      },
    );
  }

  Future<void> _addArticle(BuildContext context, WidgetRef ref) async {
    final newArticle = Article(
      title: 'Untitled Article',
      content: '',
      translatedContent: null,
    );

    final id = await ref.read(articlesProvider.notifier).addArticle(newArticle);

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ArticleEditPage(articleId: id),
        ),
      );
    }
  }

  void _editArticle(BuildContext context, Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArticleEditPage(articleId: article.id),
      ),
    );
  }

  Future<void> _saveAsArticle(
    BuildContext context,
    WidgetRef ref,
    Article article,
  ) async {
    final newId = await ref.read(articlesProvider.notifier).saveAsArticle(article);

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ArticleEditPage(articleId: newId),
        ),
      );
    }
  }

  Future<void> _resetProgress(
    BuildContext context,
    WidgetRef ref,
    Article article,
  ) async {
    final dao = SkillProgressDao();
    await dao.resetProgressForArticle(article.id!);

    // Force refresh the article list to update progress display
    ref.read(articlesProvider.notifier).loadArticles();
  }

  Future<void> _deleteArticle(
    BuildContext context,
    WidgetRef ref,
    Article article,
  ) async {
    await ref.read(articlesProvider.notifier).deleteArticle(article.id!);
  }

  void _openReadingPractice(BuildContext context, Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReadingPracticePage(article: article),
      ),
    );
  }

  void _openWritingPractice(BuildContext context, Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WritingPracticePage(article: article),
      ),
    );
  }

  void _openListeningPractice(BuildContext context, Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListeningPracticePage(article: article),
      ),
    );
  }

  void _openSpeakingPractice(BuildContext context, Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SpeakingPracticePage(article: article),
      ),
    );
  }
}
