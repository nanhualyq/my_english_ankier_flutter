import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/skill_progress_dao.dart';
import '../models/article.dart';
import '../providers/skill_progress_provider.dart';
import '../models/selected_content.dart';
import '../models/skill_type.dart';
import '../services/anki_connect_service.dart';
import '../services/youdao_dict_service.dart';
import '../utils/anki_field_builder.dart';
import '../widgets/practice_line_item.dart';
import '../widgets/anki_shortcut_mixin.dart';
import '../widgets/practice_selection_bar.dart';

/// 阅读练习页面，支持逐行显示原文和译文切换，以及文本选中与提取
class ReadingPracticePage extends ConsumerStatefulWidget {
  final Article article;

  const ReadingPracticePage({super.key, required this.article});

  @override
  ConsumerState<ReadingPracticePage> createState() => _ReadingPracticePageState();
}

class _ReadingPracticePageState extends ConsumerState<ReadingPracticePage>
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
      SkillType.reading,
    );
    if (!mounted) return;
    final position = progress?.lastLinePosition ?? 0;
    setState(() {
      _lastLinePosition = position;
    });
    if (position > 0 && _scrollController.hasClients) {
      final lines = widget.article.content.split('\n');
      final targetIndex = position.clamp(0, lines.length - 1);
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

    // 查询有道词典释义
    String back = '';
    try {
      final youdao = YoudaoDictService();
      final result = await youdao.lookup(_selection!.selectedText);
      if (result != null && result.hasEntries) {
        back = result.toBackField();
      }
    } catch (_) {
      // 查询失败时 back 为空，不影响流程
    }

    // 构建 Front 字段 HTML
    final front = buildAnkiFrontField(widget.article.content, _selection!);

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
          SkillType.reading,
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
      body: buildWithAnkiShortcuts(
        child: widget.article.content.isEmpty
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

  /// 文章内容为空时显示的提示
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Article content is empty',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// 构建内容列表
  Widget _buildContentList(List<String> lines, List<String> translations) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final line = lines[index];
        final translation = index < translations.length
            ? translations[index]
            : null;

        return PracticeLineItem(
          lineNumber: index + 1,
          primaryText: line,
          secondaryText: translation,
          primaryLabel: 'translation',
          secondaryLabel: 'translation',
          onSelected: _onContentSelected,
          isLearned: (index + 1) <= _lastLinePosition,
        );
      },
    );
  }
}
