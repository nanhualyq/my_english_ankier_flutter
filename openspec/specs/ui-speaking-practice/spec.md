## Purpose

提供口语练习界面，让用户通过"边看边读"的方式训练口语能力。每行始终显示原文和 TTS 播放按钮，用户可以跟读并选中需要重点练习的部分。

## Requirements

### Requirement: 进入口语练习页面
用户点击文章卡片上的口语技能（🗣️）时，系统必须导航到该文章的口语练习页面。

#### Scenario: 成功进入口语练习页面
- **WHEN** 用户在文章卡片上点击口语技能图标（🗣️）
- **THEN** 系统导航到口语练习页面，页面标题显示文章标题

#### Scenario: 文章内容为空
- **WHEN** 文章的content字段为空字符串
- **THEN** 页面显示提示信息"Article content is empty"

### Requirement: 逐行显示原文和 TTS
口语练习页面必须将文章内容按行分割，每行始终显示原文文本和 TTS 播放按钮，无需展开操作。

#### Scenario: 正常显示多行内容
- **WHEN** 文章content包含多行文本（以换行符分隔）
- **THEN** 页面以列表形式逐行显示，每行包含行号、原文文本和 TTS 播放按钮

#### Scenario: 内容只有一行
- **WHEN** 文章content只包含一行文本
- **THEN** 页面显示一行，包含行号、原文文本和 TTS 播放按钮

### Requirement: 原文可选中
原文必须支持文本选中操作。

#### Scenario: 原文可选中
- **WHEN** 用户在原文区域长按或拖动选择文本
- **THEN** 系统显示文本选区高亮，用户可以选中任意连续文本片段

#### Scenario: 选区为单行内
- **WHEN** 用户选中文本
- **THEN** 选区限制在当前行内，不支持跨行选中

### Requirement: 选区替换模式
系统同一时间只保留一个选区，新选区替换旧选区。

#### Scenario: 新选区替换旧选区
- **WHEN** 用户已经选中一段文本后又选中另一段文本
- **THEN** 系统清除旧选区，只保留新选区

### Requirement: 提取选中内容到 Anki
用户选中文本后，必须能够将选中内容发送到 Anki 的添加卡片界面。

#### Scenario: 正常提取
- **WHEN** 用户选中一段文本并点击提取按钮
- **THEN** 系统打开 Anki 的添加卡片界面，deck 为 "English"，notetype 为 "@EnSpeak"
- **AND** Front 字段包含当前行上下文（最多3行上方上下文），当前行的选中部分用 `<mark>` 包裹
- **AND** Back 字段包含选中的原文文本

#### Scenario: AnkiConnect 不可用
- **WHEN** 用户点击提取按钮但 AnkiConnect 服务不可用
- **THEN** 系统显示错误提示 "Cannot connect to Anki. Is Anki running?"

### Requirement: 页面布局和交互
口语练习页面必须提供清晰的布局和流畅的交互体验。

#### Scenario: 页面可滚动
- **WHEN** 文章内容超过屏幕显示范围
- **THEN** 页面支持垂直滚动查看所有内容

#### Scenario: TTS 按钮单独一行显示
- **WHEN** 每行原文显示时
- **THEN** TTS 播放按钮在原文下方单独一行显示
