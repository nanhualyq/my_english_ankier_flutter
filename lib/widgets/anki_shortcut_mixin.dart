import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/selected_content.dart';

/// 为练习页面提供 Anki 提取快捷键支持的 Mixin
///
/// 使用方式：
/// ```dart
/// class _MyPracticePageState extends State<MyPracticePage>
///     with AnkiShortcutMixin {
///
///   @override
///   SelectedContent? get selection => _selection;
///
///   @override
///   void onExtractSelection() => _extractSelection();
///
///   @override
///   void onCopyToClipboard() => _copyToClipboard();
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: buildWithAnkiShortcuts(
///         child: Stack(/* ... */),
///       ),
///     );
///   }
/// }
/// ```
mixin AnkiShortcutMixin<T extends StatefulWidget> on State<T> {
  /// 当前选中的内容，null 表示无选区
  SelectedContent? get selection;

  /// 触发 Anki 提取操作
  void onExtractSelection();

  /// 复制选中文本到剪贴板
  void onCopyToClipboard();

  /// 包裹子类的 body 内容，添加键盘快捷键支持
  ///
  /// - `Ctrl+E`：触发 Anki 提取（仅在有选区时生效）
  Widget buildWithAnkiShortcuts({required Widget child}) {
    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyE,
        ): () {
          if (selection != null) onExtractSelection();
        },
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}