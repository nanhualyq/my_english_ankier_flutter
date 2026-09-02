/// 选中内容的数据模型
/// 用于捕获用户在阅读页面选中的文本片段
class SelectedContent {
  /// 行号（1-based）
  final int lineNumber;

  /// 完整行的原文文本
  final String lineText;

  /// 用户选中的文本片段
  final String selectedText;

  /// 选区在行文本中的起始位置
  final int start;

  /// 选区在行文本中的结束位置
  final int end;

  /// 是否来自译文区域
  final bool isTranslation;

  const SelectedContent({
    required this.lineNumber,
    required this.lineText,
    required this.selectedText,
    required this.start,
    required this.end,
    this.isTranslation = false,
  });

  @override
  String toString() {
    return 'SelectedContent(line: $lineNumber, text: "$selectedText", range: $start-$end, isTranslation: $isTranslation)';
  }
}
