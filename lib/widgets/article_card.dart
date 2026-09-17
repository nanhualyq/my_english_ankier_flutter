import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../models/skill_progress.dart';
import '../models/skill_type.dart';
import '../database/skill_progress_dao.dart';
import 'skill_progress_widget.dart';

/// A card displaying article title, skill progress, and a context menu.
class ArticleCard extends ConsumerWidget {
  final Article article;
  final VoidCallback onEdit;
  final VoidCallback onSaveAs;
  final VoidCallback onResetProgress;
  final VoidCallback onDelete;
  final VoidCallback onListeningPractice;
  final VoidCallback onSpeakingPractice;
  final VoidCallback onReadingPractice;
  final VoidCallback onWritingPractice;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onEdit,
    required this.onSaveAs,
    required this.onResetProgress,
    required this.onDelete,
    required this.onListeningPractice,
    required this.onSpeakingPractice,
    required this.onReadingPractice,
    required this.onWritingPractice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(context, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('编辑'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'save_as',
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 18),
                          SizedBox(width: 8),
                          Text('另存为'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'reset_progress',
                      child: Row(
                        children: [
                          Icon(Icons.refresh, size: 18),
                          SizedBox(width: 8),
                          Text('重置进度'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('删除', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            _ProgressRow(
              articleId: article.id!,
              totalLines: article.totalLines,
              onListeningTap: onListeningPractice,
              onSpeakingTap: onSpeakingPractice,
              onReadingTap: onReadingPractice,
              onWritingTap: onWritingPractice,
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        onEdit();
        break;
      case 'save_as':
        onSaveAs();
        break;
      case 'reset_progress':
        _showResetProgressDialog(context);
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  void _showResetProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置进度'),
        content: Text('确定要重置「${article.title}」的所有学习进度吗？\n文章内容不会受影响。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onResetProgress();
            },
            child: const Text('重置', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除文章'),
        content: Text('确定要删除「${article.title}」吗？\n此操作不可撤销，所有学习进度也会被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Loads and displays skill progress for an article.
class _ProgressRow extends ConsumerWidget {
  final int articleId;
  final int totalLines;
  final VoidCallback? onListeningTap;
  final VoidCallback? onSpeakingTap;
  final VoidCallback? onReadingTap;
  final VoidCallback? onWritingTap;

  const _ProgressRow({
    required this.articleId,
    required this.totalLines,
    this.onListeningTap,
    this.onSpeakingTap,
    this.onReadingTap,
    this.onWritingTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = SkillProgressDao();

    return FutureBuilder<List<SkillProgress>>(
      future: dao.getSkillProgressForArticle(articleId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SkillProgressWidget(
            listeningProgress: 0,
            speakingProgress: 0,
            readingProgress: 0,
            writingProgress: 0,
            onListeningTap: onListeningTap,
            onSpeakingTap: onSpeakingTap,
            onReadingTap: onReadingTap,
            onWritingTap: onWritingTap,
          );
        }

        final progressList = snapshot.data!;
        double getProgress(String skillType) {
          final matches = progressList.where((p) => p.skillType == skillType);
          if (matches.isEmpty) return 0;
          final linePos = matches.first.lastLinePosition;
          if (totalLines <= 0) return 0;
          return (linePos / totalLines).clamp(0.0, 1.0);
        }

        return SkillProgressWidget(
          listeningProgress: getProgress(SkillType.listening.name),
          speakingProgress: getProgress(SkillType.speaking.name),
          readingProgress: getProgress(SkillType.reading.name),
          writingProgress: getProgress(SkillType.writing.name),
          onListeningTap: onListeningTap,
          onSpeakingTap: onSpeakingTap,
          onReadingTap: onReadingTap,
          onWritingTap: onWritingTap,
        );
      },
    );
  }
}
