import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/article.dart';
import '../models/selected_content.dart';
import '../services/anki_connect_service.dart';
import '../utils/anki_field_builder.dart';
import '../widgets/practice_line_item.dart';
import '../widgets/practice_selection_bar.dart';
import '../widgets/tts_play_button.dart';

/// 口语练习页面，支持逐行显示原文和 TTS 播放
class SpeakingPracticePage extends StatefulWidget {
  final Article article;

  const SpeakingPracticePage({super.key, required this.article});

  @override
  State<SpeakingPracticePage> createState() => _SpeakingPracticePageState();
}

class _SpeakingPracticePageState extends State<SpeakingPracticePage> {
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

    // 构建 Front 字段 HTML，选中部分用 <mark> 包裹
    final front = buildAnkiFrontField(widget.article.content, _selection!);

    // Back 字段为选中的原文
    final back = _selection!.selectedText;

    try {
      await anki.guiAddCards(
        deckName: 'English',
        modelName: '@EnSpeak',
        fields: {'Front': front, 'Back': back},
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
      body: widget.article.content.isEmpty
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
  Widget _buildContentList(List<String> lines) {
    return ListView.builder(
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
          trailing: TtsPlayButton(text: line),
        );
      },
    );
  }
}
