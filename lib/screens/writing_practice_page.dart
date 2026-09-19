import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/skill_progress_dao.dart';
import '../models/article.dart';
import '../providers/skill_progress_provider.dart';
import '../models/selected_content.dart';
import '../models/skill_type.dart';
import '../services/anki_connect_service.dart';
import '../utils/anki_field_builder.dart';
import '../widgets/practice_line_item.dart';
import '../widgets/anki_shortcut_mixin.dart';
import '../widgets/practice_selection_bar.dart';

/// 写作练习页面，支持逐行显示译文和原文切换，以及文本选中与提取
class WritingPracticePage extends ConsumerStatefulWidget {
  final Article article;

  const WritingPracticePage({super.key, required this.article});

  @override
  ConsumerState<WritingPracticePage> createState() => _WritingPracticePageState();
}

class _WritingPracticePageState extends ConsumerState<WritingPracticePage>
    with AnkiShortcutMixin {
  /// 当前选中的内容，null 表示无选区
  SelectedContent? _selection;

  /// 滚动控制器，用于恢复上次学习位置
  final ScrollController _scrollController = ScrollController();

  /// 上次学到的行号（1-based），0 表示无记录
  int _lastLinePosition = 0;

  final SkillProgressDao _skillProgressDao = SkillProgressDao();

  @override
  void initState() {
    super.initState();
    _loadLastLinePosition();
  }

  /// 从数据库读取上次学到的行号，并在首帧后滚动到目标位置
  Future<void> _loadLastLinePosition() async {
    if (widget.article.id == null) return;
    final progress = await _skillProgressDao.getSkillProgress(
      widget.article.id!,
      SkillType.writing,
    );
    if (!mounted) return;
    final position = progress?.lastLinePosition ?? 0;
    setState(() {
      _lastLinePosition = position;
    });
    if (position > 0 && _scrollController.hasClients) {
      final translations = widget.article.translatedContent?.split('\n') ?? [];
      final targetIndex = position.clamp(0, translations.length - 1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(targetIndex * 60.0);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  SelectedContent? get selection => _selection;

  @override
  void onExtractSelection() => _extractSelection();

  @override
  void onCopyToClipboard() => _copyToClipboard();

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

    // 构建 Front 字段 HTML（使用译文内容）
    final translatedContent = widget.article.translatedContent ?? '';
    final front = buildAnkiFrontField(translatedContent, _selection!);

    // Back 字段为空（写作页面不查询有道词典）
    const back = '';

    try {
      await anki.guiAddCards(
        deckName: 'English',
        modelName: '@Basic',
        fields: {'Front': front, 'Back': back},
      );
      if (!mounted) return;
      // 更新学习位置
      final lineNumber = _selection!.lineNumber;
      if (widget.article.id != null && lineNumber > _lastLinePosition) {
        await _skillProgressDao.updateLastLinePosition(
          widget.article.id!,
          SkillType.writing,
          lineNumber,
        );
        ref.invalidate(skillProgressListProvider(widget.article.id!));
        setState(() {
          _lastLinePosition = lineNumber;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    // 解析译文为列表（主内容）
    final translations = widget.article.translatedContent?.split('\n') ?? [];
    // 解析原文为列表（可展开内容）
    final originalLines = widget.article.content.split('\n');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: buildWithAnkiShortcuts(
        child: translations.isEmpty
            ? _buildEmptyState(context)
            : Stack(
              children: [
                _buildContentList(translations, originalLines),
                // 底部浮动选区栏
                if (_selection != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: PracticeSelectionBar(
                      selection: _selection!,
                      onCopy: _copyToClipboard,
                      onExtract: _extractSelection,
                      onDismiss: () => _onContentSelected(null),
                    ),
                  ),
              ],
            ),
        ),
      );
  }

  /// 译文为空时显示的提示
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.translate_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Translation is not available',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// 构建内容列表
  Widget _buildContentList(
    List<String> translations,
    List<String> originalLines,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: translations.length,
      itemBuilder: (context, index) {
        final translation = translations[index];
        final original = index < originalLines.length
            ? originalLines[index]
            : null;

        return PracticeLineItem(
          lineNumber: index + 1,
          primaryText: translation,
          secondaryText: original,
          primaryLabel: 'original',
          secondaryLabel: 'original',
          onSelected: _onContentSelected,
          isLearned: (index + 1) <= _lastLinePosition,
        );
      },
    );
  }
}
