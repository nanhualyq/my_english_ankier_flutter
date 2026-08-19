import 'package:flutter/material.dart';
import '../models/article.dart';

/// 阅读练习页面，支持逐行显示原文和译文切换
class ReadingPracticePage extends StatelessWidget {
  final Article article;

  const ReadingPracticePage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    // 解析文章内容为行列表
    final lines = article.content.split('\n');
    // 解析译文为列表（如果存在）
    final translations = article.translatedContent?.split('\n') ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: article.content.isEmpty
          ? _buildEmptyState(context)
          : _buildContentList(lines, translations),
    );
  }

  /// 文章内容为空时显示的提示
  Widget _buildEmptyState(BuildContext context) {
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
            '文章内容为空',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  /// 构建内容列表
  Widget _buildContentList(List<String> lines, List<String> translations) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final line = lines[index];
        // 获取对应译文（如果存在）
        final translation = index < translations.length ? translations[index] : null;

        return ReadingLineItem(
          lineNumber: index + 1,
          text: line,
          translation: translation,
        );
      },
    );
  }
}

/// 单行阅读内容组件
class ReadingLineItem extends StatefulWidget {
  final int lineNumber;
  final String text;
  final String? translation;

  const ReadingLineItem({
    super.key,
    required this.lineNumber,
    required this.text,
    this.translation,
  });

  @override
  State<ReadingLineItem> createState() => _ReadingLineItemState();
}

class _ReadingLineItemState extends State<ReadingLineItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasTranslation = widget.translation != null && widget.translation!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 原文区域
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),

          // 译文切换控件（如果译文存在）
          if (hasTranslation)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      _isExpanded ? Icons.expand_more : Icons.chevron_right,
                      size: 20,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isExpanded ? '收起译文' : '显示译文',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 译文显示区域（展开后显示）
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _isExpanded && hasTranslation
                ? Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Colors.grey[400]!,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      widget.translation!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
