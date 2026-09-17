import 'package:flutter/material.dart';
import '../models/selected_content.dart';

/// 通用逐行练习内容组件
/// 用于阅读、写作、听力、口语等练习页面，支持主文本显示和次文本展开/折叠
class PracticeLineItem extends StatefulWidget {
  final int lineNumber;
  final String primaryText;
  final String? secondaryText;
  final String primaryLabel;
  final String secondaryLabel;
  final ValueChanged<SelectedContent?>? onSelected;

  /// 是否显示主文本。听力模式传 false，默认只显示 TTS。
  final bool showPrimaryText;

  /// 主文本是否可通过展开/折叠控制可见性。听力模式传 true。
  final bool primaryTextExpandable;

  /// 主文本下方的附加组件（如 TTS 播放按钮）。
  final Widget? trailing;

  const PracticeLineItem({
    super.key,
    required this.lineNumber,
    required this.primaryText,
    this.secondaryText,
    required this.primaryLabel,
    required this.secondaryLabel,
    this.onSelected,
    this.showPrimaryText = true,
    this.primaryTextExpandable = false,
    this.trailing,
  });

  @override
  State<PracticeLineItem> createState() => _PracticeLineItemState();
}

class _PracticeLineItemState extends State<PracticeLineItem> {
  bool _isExpanded = false;

  /// 处理主文本选区变化
  void _onPrimarySelectionChanged(
      TextSelection selection, SelectionChangedCause? cause) {
    _handleSelection(selection, isTranslation: false);
  }

  /// 处理次文本选区变化
  void _onSecondarySelectionChanged(
      TextSelection selection, SelectionChangedCause? cause) {
    _handleSelection(selection, isTranslation: true);
  }

  /// 通用选区处理逻辑
  void _handleSelection(TextSelection selection,
      {required bool isTranslation}) {
    final sourceText =
        isTranslation ? widget.secondaryText! : widget.primaryText;

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
      lineText: widget.primaryText,
      selectedText: selectedText,
      start: start,
      end: end,
      isTranslation: isTranslation,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final hasSecondary = widget.secondaryText != null &&
        widget.secondaryText!.isNotEmpty;

    // 是否有展开/折叠需求（次文本 或 可展开的主文本）
    final hasExpandable = hasSecondary || widget.primaryTextExpandable;

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
          // 主文本区域（当 showPrimaryText=true 且非 primaryTextExpandable 时始终显示）
          if (widget.showPrimaryText && !widget.primaryTextExpandable)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SelectableText(
                widget.primaryText,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
                onSelectionChanged: _onPrimarySelectionChanged,
              ),
            ),

          // Trailing 附加组件（如 TTS 播放按钮）
          if (widget.trailing != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: widget.trailing!,
            ),

          // 展开/折叠控件
          if (hasExpandable)
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
                      _isExpanded
                          ? 'Hide ${widget.secondaryLabel}'
                          : 'Show ${widget.secondaryLabel}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 展开后的内容区域
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? _buildExpandedContent(hasSecondary)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// 构建展开后的内容
  Widget _buildExpandedContent(bool hasSecondary) {
    // primaryTextExpandable 模式：展开后显示主文本
    if (widget.primaryTextExpandable) {
      return Container(
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
          widget.primaryText,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.5,
          ),
          onSelectionChanged: _onPrimarySelectionChanged,
        ),
      );
    }

    // 默认模式：展开后显示次文本
    if (hasSecondary) {
      return Container(
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
          widget.secondaryText!,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.5,
          ),
          onSelectionChanged: _onSecondarySelectionChanged,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
