## Purpose

提供写作练习界面，让用户能够逐行阅读译文并选中片段添加到 Anki，隐藏原文以模拟写作/翻译场景，支持按需展开原文对照。

## ADDED Requirements

### Requirement: 进入写作练习页面
用户点击文章卡片上的写作技能（✍️）时，系统必须导航到该文章的写作练习页面。

#### Scenario: 成功进入写作练习页面
- **WHEN** 用户在文章卡片上点击写作技能图标（✍️）
- **THEN** 系统导航到写作练习页面，页面标题显示文章标题

#### Scenario: 文章译文为空
- **WHEN** 文章的translatedContent为空或空字符串
- **THEN** 页面显示提示信息"Translation is not available"

### Requirement: 逐行显示译文内容
写作练习页面必须将译文按行分割，并逐行显示译文作为主内容。

#### Scenario: 正常显示多行译文
- **WHEN** 文章translatedContent包含多行文本（以换行符分隔）
- **THEN** 页面以列表形式逐行显示每一行译文

#### Scenario: 译文行数少于原文
- **WHEN** 原文有10行，译文只有8行
- **THEN** 前8行正常显示译文，后2行不显示

### Requirement: 原文切换控件
每行译文下方必须显示一个独立的切换控件，用于控制对应原文的显示和隐藏。

#### Scenario: 原文存在时显示切换控件
- **WHEN** 文章的content存在且对应行有原文
- **THEN** 该行下方显示"Show original"切换控件

#### Scenario: 原文不存在时不显示控件
- **WHEN** 文章的content为空或对应行没有原文
- **THEN** 该行下方不显示切换控件

### Requirement: 原文显示和隐藏
用户点击切换控件时，必须在对应行下方的新行中显示或隐藏原文。

#### Scenario: 点击显示原文
- **WHEN** 用户点击某行的"Show original"控件
- **THEN** 在该行下方的新行中显示对应原文，控件文本变为"Hide original"

#### Scenario: 点击收起原文
- **WHEN** 用户点击某行的"Hide original"控件
- **THEN** 隐藏该行的原文，控件文本变回"Show original"

#### Scenario: 多行原文独立控制
- **WHEN** 用户同时查看多行原文
- **THEN** 每行的原文显示状态独立控制，互不影响

### Requirement: 文本可选中
写作练习页面中的译文和原文必须支持文本选中操作。

#### Scenario: 译文可选中
- **WHEN** 用户在译文区域长按或拖动选择文本
- **THEN** 系统显示文本选区高亮，用户可以选中任意连续文本片段

#### Scenario: 原文可选中
- **WHEN** 用户展开原文后在原文区域长按或拖动选择文本
- **THEN** 系统显示文本选区高亮，用户可以选中任意连续文本片段

#### Scenario: 选区为单行内
- **WHEN** 用户选中文本
- **THEN** 选区限制在当前行内（译文或原文），不支持跨行选中

### Requirement: 选区替换模式
系统同一时间只保留一个选区，新选区替换旧选区。

#### Scenario: 新选区替换旧选区
- **WHEN** 用户已经选中一段文本后又选中另一段文本
- **THEN** 系统清除旧选区，只保留新选区

#### Scenario: 选区清除
- **WHEN** 用户点击选区外的区域
- **THEN** 系统清除当前选区

### Requirement: 选区操作栏
当用户选中文本时，页面底部必须显示浮动操作栏，提供复制和提取到 Anki 的功能。

#### Scenario: 选中文本后显示操作栏
- **WHEN** 用户选中任意非空文本
- **THEN** 页面底部显示浮动操作栏，包含行号标签、选中文本预览、复制按钮、提取按钮和关闭按钮

#### Scenario: 无选区时隐藏操作栏
- **WHEN** 当前没有选中文本
- **THEN** 底部操作栏不显示

### Requirement: 复制选中文本
用户可以通过操作栏将选中文本复制到剪贴板。

#### Scenario: 复制成功
- **WHEN** 用户点击操作栏的复制按钮
- **THEN** 选中文本被复制到系统剪贴板，页面显示"Copied: <文本>"提示

### Requirement: 提取选中内容到 Anki
用户可以通过操作栏将选中内容发送到 Anki 的添加卡片界面。

#### Scenario: 成功提取到 Anki
- **WHEN** 用户点击操作栏的提取按钮且 AnkiConnect 可用
- **THEN** 系统打开 Anki 的添加卡片对话框，Front 字段包含选中译文的上下文（最多3行上方译文 + 当前行选中部分用 mark 标记），Back 字段为空

#### Scenario: AnkiConnect 不可用
- **WHEN** 用户点击操作栏的提取按钮但 AnkiConnect 不可用
- **THEN** 页面显示"Cannot connect to Anki. Is Anki running?"提示

#### Scenario: 提取时不查询有道词典
- **WHEN** 用户点击提取按钮
- **THEN** 系统不调用有道词典服务，Back 字段始终为空

### Requirement: 页面布局和交互
写作练习页面必须提供清晰的布局和流畅的交互体验。

#### Scenario: 页面可滚动
- **WHEN** 文章译文超过屏幕显示范围
- **THEN** 页面支持垂直滚动查看所有内容

#### Scenario: 原文展开/收起动画
- **WHEN** 用户切换原文显示状态
- **THEN** 原文区域有平滑的展开/收起动画效果

#### Scenario: 原文样式区分
- **WHEN** 原文显示时
- **THEN** 原文文本样式与译文有明显区别（如颜色、字体大小、左侧竖线等）
