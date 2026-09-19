## 1. 阅读练习 Back 字段兜底

- [x] 1.1 在 `reading_practice_page.dart` 的 `_extractSelection` 方法中，当有道查询返回空结果时，从 `article.translatedContent` 按行号获取对应译文行填入 Back 字段。验证：选中有道无结果的文本，检查 Anki 添加对话框中 Back 字段包含对应译文行。
- [x] 1.2 处理无对应译文行的边界情况（translatedContent 为空或行号越界时，Back 为空）。验证：对无译文的文章执行提取，Back 字段为空，不报错。

## 2. 写作练习 Back 字段填入对应行

- [x] 2.1 在 `writing_practice_page.dart` 的 `_extractSelection` 方法中，将 Back 字段从空字符串改为从 `article.content` 按行号获取对应原文行填入。验证：执行提取操作，检查 Anki 添加对话框中 Back 字段包含对应原文行。
- [x] 2.2 处理无对应原文行的边界情况（content 行号越界时，Back 为空）。验证：对原文行数少于译文行数的文章执行提取，Back 字段为空，不报错。
