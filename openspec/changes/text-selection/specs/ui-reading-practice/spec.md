## Purpose (Delta)

为阅读练习页面增加文本选中、复制和提取功能，使用户能够选中原文或译文中的任意文本片段，并进行复制或提取操作。这是对现有 `ui-reading-practice` 能力的增强。

## Requirements

### Requirement: 文本可选中

阅读练习页面中的原文和译文必须支持文本选中操作。

#### Scenario: 原文可选中
- **WHEN** 用户在原文区域长按或拖动选择文本
- **THEN** 系统显示文本选区高亮，用户可以选中任意连续文本片段

#### Scenario: 译文可选中
- **WHEN** 用户展开译文后在译文区域长按或拖动选择文本
- **THEN** 系统显示文本选区高亮，用户可以选中任意连续文本片段

#### Scenario: 选区为单行内
- **WHEN** 用户选中文本
- **THEN** 选区限制在当前行内（原文或译文），不支持跨行选中

### Requirement: 选区替换模式

系统同一时间只保留一个选区，新选区替换旧选区。

#### Scenario: 选中A行后选中B行
- **WHEN** 用户已在A行选中文本，然后在B行选中新文本
- **THEN** 系统清除A行的选区，只保留B行的选区

#### Scenario: 取消选区
- **WHEN** 用户点击空白区域或点击已选中的文本（折叠选区）
- **THEN** 系统清除当前选区

### Requirement: 底部浮动操作栏

当用户选中文本后，页面底部必须显示浮动操作栏。

#### Scenario: 选中后显示操作栏
- **WHEN** 用户在任意行选中非空文本
- **THEN** 页面底部显示浮动操作栏，包含行号标签、选中文本预览和操作按钮

#### Scenario: 操作栏内容
- **WHEN** 浮动操作栏显示时
- **THEN** 操作栏左侧显示行号（如"L1"），中间显示选中文本（过长时截断），右侧显示"复制"和"提取"按钮以及关闭按钮

#### Scenario: 选区消失时隐藏操作栏
- **WHEN** 用户取消选区（点击空白或折叠选区）
- **THEN** 浮动操作栏消失

#### Scenario: 选区替换时更新操作栏
- **WHEN** 用户在另一行选中新文本
- **THEN** 浮动操作栏更新为新选区的信息（行号、文本预览）

### Requirement: 复制功能

用户必须能够将选中的文本复制到系统剪贴板。

#### Scenario: 点击复制按钮
- **WHEN** 用户在浮动操作栏点击"Copy"按钮
- **THEN** 选中文本写入系统剪贴板，页面显示 SnackBar 提示"Copied: xxx"

#### Scenario: 复制后选区保持
- **WHEN** 用户点击"Copy"按钮
- **THEN** 复制操作完成后选区保持不变，操作栏仍然显示

### Requirement: 提取功能

用户必须能够提取选中的文本内容，为后续 Anki 集成做准备。

#### Scenario: 点击提取按钮
- **WHEN** 用户在浮动操作栏点击"Extract"按钮
- **THEN** 系统记录选中内容的完整信息（行号、完整行文本、选中片段、选区范围、是否译文），页面显示 SnackBar 提示已提取

#### Scenario: 提取数据结构
- **WHEN** 执行提取操作
- **THEN** 提取的数据包含：lineNumber（行号，1-based）、lineText（完整行原文）、selectedText（选中片段）、start/end（选区范围）、isTranslation（是否来自译文）

### Requirement: 数据模型

系统必须提供 `SelectedContent` 数据模型来承载选中信息。

#### Scenario: 模型字段完整性
- **WHEN** 创建 `SelectedContent` 实例
- **THEN** 必须包含 lineNumber、lineText、selectedText、start、end 字段，以及可选的 isTranslation 字段（默认 false）

## Affected Files

- `lib/models/selected_content.dart`（新增）
- `lib/screens/reading_practice_page.dart`（修改）
