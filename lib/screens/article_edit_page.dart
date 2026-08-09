import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/articles_provider.dart';
import '../database/article_dao.dart';

/// Edit page for article title, content, and optional translation.
class ArticleEditPage extends ConsumerStatefulWidget {
  final int? articleId;

  const ArticleEditPage({super.key, this.articleId});

  @override
  ConsumerState<ArticleEditPage> createState() => _ArticleEditPageState();
}

class _ArticleEditPageState extends ConsumerState<ArticleEditPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _translationController = TextEditingController();
  final _urlController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    if (widget.articleId == null) {
      // New article — already created by the caller, just mark as loaded
      setState(() => _isLoading = false);
      return;
    }

    final dao = ArticleDao();
    final article = await dao.getArticleById(widget.articleId!);
    if (article != null) {
      _titleController.text = article.title;
      _contentController.text = article.content;
      _translationController.text = article.translatedContent ?? '';
      _urlController.text = article.url ?? '';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    if (widget.articleId == null) return;

    final dao = ArticleDao();
    final article = await dao.getArticleById(widget.articleId!);
    if (article == null) return;

    final updated = article.copyWith(
      title: _titleController.text.isEmpty ? '未命名文章' : _titleController.text,
      content: _contentController.text,
      translatedContent: _translationController.text.isEmpty
          ? null
          : _translationController.text,
      url: _urlController.text.isEmpty ? null : _urlController.text,
      updatedAt: DateTime.now(),
    );

    await ref.read(articlesProvider.notifier).updateArticle(updated);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _translationController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑文章'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _save,
            tooltip: '保存',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '标题',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: '文章标题',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '来源 URL（可选）',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        hintText: 'https://example.com/article',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '英文内容',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _contentController,
                      maxLines: null,
                      minLines: 10,
                      decoration: const InputDecoration(
                        hintText: '粘贴英文文章内容...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '中文译文（可选）',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _translationController,
                      maxLines: null,
                      minLines: 8,
                      decoration: const InputDecoration(
                        hintText: '粘贴中文翻译...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
