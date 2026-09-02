## Why

用户在阅读练习页面阅读英文文章时，经常需要选中特定单词或短语进行查词、翻译或记录到 Anki 卡片中。当前页面使用普通 `Text` widget，不支持文本选中和复制，用户无法与文本内容进行选择交互。需要支持文本选中功能，并提供提取选中内容的能力，为后续 Anki 集成做准备。

## What Changes

- 阅读练习页面中的原文和译文支持文本选中（`Text` → `SelectableText`）
- 用户选中文本后，页面底部显示浮动操作栏，展示选中内容预览
- 浮动栏提供"复制"功能，将选中文本写入剪贴板
- 浮动栏提供"提取"功能，暂存选中内容（预留 Anki 接口）
- 新增 `SelectedContent` 数据模型，承载选中信息（行号、完整行文本、选中片段、选区范围、是否译文）
- 选区行为为替换模式：同一时间只保留一个选区

## Capabilities

### Modified Capabilities
- `ui-reading-practice`: 增加文本选中、复制和提取功能

## Impact

- 新增文件：`lib/models/selected_content.dart`
- 修改文件：`lib/screens/reading_practice_page.dart`
- 无依赖变更，无 API 变更
- 使用 Flutter 内置 `SelectableText` 和 `Clipboard` API
