import '../models/selected_content.dart';

/// 构建 Anki Front 字段的 HTML 内容
///
/// 格式：最多3行上方上下文 + 当前行（选中部分用 <mark> 包裹）+ 隐藏时间戳
///
/// [content] 完整的文章内容（原文或译文），用于提取上下文行
/// [selection] 用户的选区信息
/// [highlightReplacement] 选中部分的替换文本。为空时使用原文，传 '???' 时替换为问号。
String buildAnkiFrontField(String content, SelectedContent selection,
    {String highlightReplacement = ''}) {
  final lines = content.split('\n');
  final currentIdx = selection.lineNumber - 1; // 0-based

  // 上方最多3行上下文
  final contextStart = (currentIdx - 3).clamp(0, currentIdx);
  final buffer = StringBuffer();
  for (var i = contextStart; i < currentIdx; i++) {
    buffer.write('${lines[i]}<br>');
  }

  // 当前行：用 <mark> 包裹选中文本或替换文本
  final line = selection.lineText;
  final before = line.substring(0, selection.start);
  final selected = highlightReplacement.isEmpty
      ? line.substring(selection.start, selection.end)
      : highlightReplacement;
  final after = line.substring(selection.end);
  buffer.write(before);
  buffer.write('<mark>$selected</mark>');
  buffer.write(after);

  // 隐藏时间戳（用于去重）
  buffer.write(
    '<span style="display:none">${DateTime.now().millisecondsSinceEpoch}</span>',
  );

  return buffer.toString();
}
