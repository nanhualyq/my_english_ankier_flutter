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
import '../widgets/tts_play_button.dart';

/// 听力练习页面，支持逐行 TTS 播放和展开查看原文
class ListeningPracticePage extends ConsumerStatefulWidget {
  final Article article;

  const ListeningPracticePage({super.key, required this.article});

  @override
  ConsumerState<ListeningPracticePage> createState() => _ListeningPracticePageState();
}

class _ListeningPracticePageState extends ConsumerState<ListeningPracticePage>
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
      SkillType.listening,
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
          _scrollController.jumpTo(
            targetIndex * 60.0,
            // 使用 estimatedItemExtent 近似
          );
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

    // 构建 Front 字段 HTML，选中部分替换为 ???
    final front = buildAnkiFrontField(
      widget.article.content,
      _selection!,
      highlightReplacement: '???',
    );

    // Back 字段为选中的原文
    final back = _selection!.selectedText;

    // 查询有道词典获取音标
    String phone = '';
    try {
      final youdao = YoudaoDictService();
      final result = await youdao.lookup(_selection!.selectedText);
      if (result != null && result.phonetics.isNotEmpty) {
        phone = result.phonetics
            .map((p) => '${p.region} /${p.text}/')
            .join(' ');
      }
    } catch (_) {
      // 查询失败时 phone 为空，不影响流程
    }

    try {
      await anki.guiAddCards(
        deckName: 'English',
        modelName: '@EnListen',
        fields: {
          'Front': front,
          'Back': back,
          'Phone': phone,
          'Title': widget.article.title,
          'Url': widget.article.url ?? '',
        },
      );
      if (!mounted) return;
      // 更新学习位置
      final lineNumber = _selection!.lineNumber;
      if (widget.article.id != null && lineNumber > _lastLinePosition) {
        await _skillProgressDao.updateLastLinePosition(
          widget.article.id!,
          SkillType.listening,
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
                _buildContentList(lines),
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
  Widget _buildContentList(List<String> lines) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final line = lines[index];

        return PracticeLineItem(
          lineNumber: index + 1,
          primaryText: line,
          primaryLabel: 'original',
          secondaryLabel: 'original',
          onSelected: _onContentSelected,
          showPrimaryText: false,
          primaryTextExpandable: true,
          trailing: TtsPlayButton(text: line),
          isLearned: (index + 1) <= _lastLinePosition,
        );
      },
    );
  }
}
