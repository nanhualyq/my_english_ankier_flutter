## Purpose

提供阅读练习界面，让用户能够逐行阅读英文文章并按需查看对应译文，支持译文的显示/隐藏切换功能，以及文本选中、复制和提取功能。

## Requirements

### Requirement: 进入阅读练习页面
用户点击文章卡片上的阅读技能（📖）时，系统必须导航到该文章的阅读练习页面。

#### Scenario: 成功进入阅读练习页面
- **WHEN** 用户在文章卡片上点击阅读技能图标（📖）
- **THEN** 系统导航到阅读练习页面，页面标题显示文章标题

#### Scenario: 文章内容为空
- **WHEN** 文章的content字段为空字符串
- **THEN** 页面显示提示信息"文章内容为空"

### Requirement: 逐行显示文章内容
阅读练习页面必须将文章内容按行分割，并逐行显示原文。

#### Scenario: 正常显示多行内容
- **WHEN** 文章content包含多行文本（以换行符分隔）
- **THEN** 页面以列表形式逐行显示每一行原文

#### Scenario: 内容只有一行
- **WHEN** 文章content只包含一行文本
- **THEN** 页面显示该行原文

### Requirement: 译文切换控件
每行原文下方必须显示一个独立的切换控件，用于控制对应译文的显示和隐藏。

#### Scenario: 译文存在时显示切换控件
- **WHEN** 文章的translatedContent存在且对应行有译文
- **THEN** 该行下方显示"显示译文"切换控件

#### Scenario: 译文不存在时不显示控件
- **WHEN** 文章的translatedContent为空或对应行没有译文
- **THEN** 该行下方不显示切换控件

### Requirement: 译文显示和隐藏
用户点击切换控件时，必须在对应行下方的新行中显示或隐藏译文。

#### Scenario: 点击显示译文
- **WHEN** 用户点击某行的"显示译文"控件
- **THEN** 在该行下方的新行中显示对应译文，控件文本变为"收起译文"

#### Scenario: 点击收起译文
- **WHEN** 用户点击某行的"收起译文"控件
- **THEN** 隐藏该行的译文，控件文本变回"显示译文"

### Requirement: 有道查询为空时 Back 字段兜底
在阅读练习页面，当用户选中文本并点击提取按钮时，若有道词典查询返回空结果，系统 SHALL 将当前行对应的译文行填入 Anki 卡片的 Back 字段作为兜底。

#### Scenario: 有道查询成功时保持现有行为
- **WHEN** 用户选中文本并点击提取按钮，且有道词典查询返回有效释义
- **THEN** Back 字段包含有道词典的释义内容，不使用对应译文行兜底

#### Scenario: 有道查询为空且有对应译文行
- **WHEN** 用户选中文本并点击提取按钮，有道词典查询返回空结果，且文章的 translatedContent 中存在与当前行对应的译文行
- **THEN** Back 字段内容为当前行对应的译文行

#### Scenario: 有道查询为空且无对应译文行
- **WHEN** 用户选中文本并点击提取按钮，有道词典查询返回空结果，且文章的 translatedContent 为空或对应行无译文
- **THEN** Back 字段为空

#### Scenario: 多行译文独立控制
- **WHEN** 用户同时查看多行译文
- **THEN** 每行的译文显示状态独立控制，互不影响

### Requirement: 译文行数不匹配处理
当译文行数与原文行数不匹配时，系统必须正确处理边界情况。

#### Scenario: 译文行数少于原文
- **WHEN** 原文有10行，译文只有8行
- **THEN** 前8行显示译文切换控件，后2行不显示控件

#### Scenario: 译文行数多于原文
- **WHEN** 原文有8行，译文有10行
- **THEN** 只显示前8行对应的译文，多余的译文被忽略

### Requirement: 页面布局和交互
阅读练习页面必须提供清晰的布局和流畅的交互体验。

#### Scenario: 页面可滚动
- **WHEN** 文章内容超过屏幕显示范围
- **THEN** 页面支持垂直滚动查看所有内容

#### Scenario: 译文展开/收起动画
- **WHEN** 用户切换译文显示状态
- **THEN** 译文区域有平滑的展开/收起动画效果

#### Scenario: 译文样式区分
- **WHEN** 译文显示时
- **THEN** 译文文本样式与原文有明显区别（如颜色、字体大小、左侧竖线等）

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

用户必须能够将选中的文本内容发送到 Anki 创建闪卡。

#### Scenario: 点击提取按钮
- **WHEN** 用户在浮动操作栏点击"Extract"按钮
- **THEN** 系统通过 AnkiConnect API 打开 Anki 的添加卡片对话框，并预填 Front 字段

#### Scenario: 提取数据结构
- **WHEN** 执行提取操作
- **THEN** 提取的数据包含：lineNumber（行号，1-based）、lineText（完整行原文）、selectedText（选中片段）、start/end（选区范围）、isTranslation（是否来自译文）

### Requirement: 提取选中内容到 Anki

用户点击浮动操作栏的"Extract"按钮后，系统必须通过 AnkiConnect API 打开 Anki 的添加卡片对话框，并预填 Front 字段。

#### Scenario: 成功打开 Anki 添加界面
- **WHEN** 用户选中文本并点击"Extract"按钮，且 Anki 已运行且 AnkiConnect 插件已安装
- **THEN** 系统调用 `guiAddCards` API，Anki 打开添加卡片对话框，Front 字段已预填内容，Back 字段为空
- **AND** title 字段包含当前文章的标题
- **AND** url 字段包含当前文章的 URL（若文章无 URL 则为空字符串）

#### Scenario: Anki 未运行
- **WHEN** 用户点击"Extract"按钮，但 Anki 未运行或 AnkiConnect 不可用
- **THEN** 系统显示 SnackBar 提示 "Cannot connect to Anki. Is Anki running?"，不执行其他操作

#### Scenario: AnkiConnect API 调用失败
- **WHEN** AnkiConnect 返回错误响应
- **THEN** 系统显示 SnackBar 提示错误信息

### Requirement: Front 字段内容格式

Front 字段必须包含上下文信息、选中文本高亮和隐藏时间戳。

#### Scenario: 上方有足够上下文
- **WHEN** 用户在第5行选中文本，上方有4行内容
- **THEN** Front 字段包含上方3行上下文 + 当前行（选中部分用 `<mark>` 包裹）+ 隐藏时间戳 `<span>`

#### Scenario: 上方不足3行上下文
- **WHEN** 用户在第2行选中文本，上方只有1行
- **THEN** Front 字段包含上方1行上下文 + 当前行（选中部分用 `<mark>` 包裹）+ 隐藏时间戳

#### Scenario: 多行之间使用 HTML 换行
- **WHEN** Front 字段包含多行上下文
- **THEN** 上下文行之间以及上下文与当前行之间使用 `<br>` 标签分隔（Anki 以 HTML 解析字段内容）

#### Scenario: 选中部分高亮
- **WHEN** 当前行文本为 "The ubiquitous nature of smartphones"，用户选中 "ubiquitous"
- **THEN** 当前行在 Front 中渲染为 "The <mark>ubiquitous</mark> nature of smartphones"

#### Scenario: 隐藏时间戳去重
- **WHEN** 用户两次选中同一段文本并分别发送到 Anki
- **THEN** 两次的 Front 字段因时间戳不同而不完全相同，Anki 不会将其判为重复卡片

### Requirement: Anki 卡片参数

系统使用硬编码参数创建卡片。

#### Scenario: 默认参数
- **WHEN** 系统调用 `guiAddCards`
- **THEN** 使用 deck=`English`、model=`@Basic`、Back 字段为空

### Requirement: AnkiConnect 服务层

系统必须通过独立的 HTTP 服务类与 AnkiConnect 通信。

#### Scenario: 连接地址
- **WHEN** 系统初始化 AnkiConnectService
- **THEN** 默认连接地址为 `http://127.0.0.1:8765`，超时时间为5秒

#### Scenario: 请求格式
- **WHEN** 系统调用 AnkiConnect API
- **THEN** 请求体为 JSON 格式，包含 `action`、`version`(=6)、`params` 字段

### Requirement: 数据模型

系统必须提供 `SelectedContent` 数据模型来承载选中信息。

#### Scenario: 模型字段完整性
- **WHEN** 创建 `SelectedContent` 实例
- **THEN** 必须包含 lineNumber、lineText、selectedText、start、end 字段，以及可选的 isTranslation 字段（默认 false）
