import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/article.dart';
import '../models/selected_content.dart';
import '../services/anki_connect_service.dart';

/// 阅读练习页面，支持逐行显示原文和译文切换，以及文本选中与提取
class ReadingPracticePage extends StatefulWidget {
  final Article article;

  const ReadingPracticePage({super.key, required this.article});

  @override
  State<ReadingPracticePage> createState() => _ReadingPracticePageState();
}

class _ReadingPracticePageState extends State<ReadingPracticePage> {
  /// 当前选中的内容，null 表示无选区
  SelectedContent? _selection;

  /// 处理子组件传递上来的选中事件
  void _onContentSelected(SelectedContent? selection) {
    setState(() {
      _selection = selection;
    });
  }

  /// 复制选中文本到剪贴板
  Future<void> _copyToClipboard() async {
    if (_selection == null) return;
    await Clipboard.setData(ClipboardData(text: _selection!.selectedText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: ${_selection!.selectedText}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 发送选中内容到 Anki 的添加卡片界面
  Future<void> _extractSelection() async {
    if (_selection == null) return;

    final anki = AnkiConnectService();

    // 检查 AnkiConnect 是否可用
    if (!await anki.isAvailable()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot connect to Anki. Is Anki running?'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 构建 Front 字段 HTML
    final front = _buildFrontField();

    try {
      await anki.guiAddCards(
        deckName: 'English',
        modelName: '@Basic',
        fields: {'Front': front, 'Back': ''},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anki Add Cards dialog opened'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Anki error: $e'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 构建 Front 字段的 HTML 内容
  ///
  /// 格式：最多3行上方上下文 + 当前行（选中部分用 <mark> 包裹）+ 隐藏时间戳
  String _buildFrontField() {
    final lines = widget.article.content.split('\n');
    final sel = _selection!;
    final currentIdx = sel.lineNumber - 1; // 0-based

    // 上方最多3行上下文
    final contextStart = (currentIdx - 3).clamp(0, currentIdx);
    final buffer = StringBuffer();
    for (var i = contextStart; i < currentIdx; i++) {
      buffer.write('${lines[i]}<br>');
    }

    // 当前行：用 <mark> 包裹选中文本
    final line = sel.lineText;
    final before = line.substring(0, sel.start);
    final selected = line.substring(sel.start, sel.end);
    final after = line.substring(sel.end);
    buffer.write(before);
    buffer.write('<mark>$selected</mark>');
    buffer.write(after);

    // 隐藏时间戳（用于去重）
    buffer.write(
      '<span style="display:none">${DateTime.now().millisecondsSinceEpoch}</span>',
    );

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    // 解析文章内容为行列表
    final lines = widget.article.content.split('\n');
    // 解析译文为列表（如果存在）
    final translations = widget.article.translatedContent?.split('\n') ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: widget.article.content.isEmpty
          ? _buildEmptyState(context)
          : Stack(
              children: [
                _buildContentList(lines, translations),
                // 底部浮动选区栏
                if (_selection != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _SelectionBar(
                      selection: _selection!,
                      onCopy: _copyToClipboard,
                      onExtract: _extractSelection,
                      onDismiss: () => _onContentSelected(null),
                    ),
                  ),
              ],
            ),
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
            'Article content is empty',
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final line = lines[index];
        final translation =
            index < translations.length ? translations[index] : null;

        return ReadingLineItem(
          lineNumber: index + 1,
          text: line,
          translation: translation,
          onSelected: _onContentSelected,
        );
      },
    );
  }
}

/// 底部浮动选区操作栏
class _SelectionBar extends StatelessWidget {
  final SelectedContent selection;
  final VoidCallback onCopy;
  final VoidCallback onExtract;
  final VoidCallback onDismiss;

  const _SelectionBar({
    required this.selection,
    required this.onCopy,
    required this.onExtract,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // 行号标签
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'L${selection.lineNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 选中文本预览（截断过长文本）
              Expanded(
                child: Text(
                  selection.selectedText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              // 操作按钮
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                tooltip: 'Copy',
                onPressed: onCopy,
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                tooltip: 'Extract',
                onPressed: onExtract,
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                tooltip: 'Close',
                onPressed: onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 单行阅读内容组件
class ReadingLineItem extends StatefulWidget {
  final int lineNumber;
  final String text;
  final String? translation;
  final ValueChanged<SelectedContent?>? onSelected;

  const ReadingLineItem({
    super.key,
    required this.lineNumber,
    required this.text,
    this.translation,
    this.onSelected,
  });

  @override
  State<ReadingLineItem> createState() => _ReadingLineItemState();
}

class _ReadingLineItemState extends State<ReadingLineItem> {
  bool _isExpanded = false;

  /// 处理原文选区变化
  void _onOriginalSelectionChanged(
      TextSelection selection, SelectionChangedCause? cause) {
    _handleSelection(selection, isTranslation: false);
  }

  /// 处理译文选区变化
  void _onTranslationSelectionChanged(
      TextSelection selection, SelectionChangedCause? cause) {
    _handleSelection(selection, isTranslation: true);
  }

  /// 通用选区处理逻辑
  void _handleSelection(TextSelection selection,
      {required bool isTranslation}) {
    final sourceText = isTranslation ? widget.translation! : widget.text;

    // 折叠选区（光标点击无实际选中）→ 清除选区
    if (selection.isCollapsed || selection.start < 0 || selection.end < 0) {
      widget.onSelected?.call(null);
      return;
    }

    // 安全截取选中文本
    final start = selection.start.clamp(0, sourceText.length);
    final end = selection.end.clamp(0, sourceText.length);
    if (start >= end) {
      widget.onSelected?.call(null);
      return;
    }

    final selectedText = sourceText.substring(start, end);
    if (selectedText.trim().isEmpty) {
      widget.onSelected?.call(null);
      return;
    }

    widget.onSelected?.call(SelectedContent(
      lineNumber: widget.lineNumber,
      lineText: widget.text,
      selectedText: selectedText,
      start: start,
      end: end,
      isTranslation: isTranslation,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final hasTranslation =
        widget.translation != null && widget.translation!.isNotEmpty;

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
            child: SelectableText(
              widget.text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
              onSelectionChanged: _onOriginalSelectionChanged,
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
                      _isExpanded ? 'Hide translation' : 'Show translation',
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
                    child: SelectableText(
                      widget.translation!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      onSelectionChanged: _onTranslationSelectionChanged,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
