import 'package:flutter/material.dart';
import '../models/selected_content.dart';

/// 通用底部浮动选区操作栏
/// 用于阅读、写作等练习页面，提供复制和提取到 Anki 的功能
class PracticeSelectionBar extends StatelessWidget {
  final SelectedContent selection;
  final VoidCallback onCopy;
  final VoidCallback onExtract;
  final VoidCallback onDismiss;

  const PracticeSelectionBar({
    super.key,
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
