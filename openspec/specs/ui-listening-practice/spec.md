## Purpose

提供听力练习界面，让用户通过"先听后看"的方式训练听力能力。每行默认只显示 TTS 播放按钮，用户听完后可展开查看原文并选中不理解的部分。

## Requirements

### Requirement: 进入听力练习页面
用户点击文章卡片上的听力技能（🎧）时，系统必须导航到该文章的听力练习页面。

#### Scenario: 成功进入听力练习页面
- **WHEN** 用户在文章卡片上点击听力技能图标（🎧）
- **THEN** 系统导航到听力练习页面，页面标题显示文章标题

#### Scenario: 文章内容为空
- **WHEN** 文章的content字段为空字符串
- **THEN** 页面显示提示信息"Article content is empty"

### Requirement: 逐行显示 TTS 播放按钮
听力练习页面必须将文章内容按行分割，每行默认只显示 TTS 播放按钮，不显示原文文本。

#### Scenario: 正常显示多行内容
- **WHEN** 文章content包含多行文本（以换行符分隔）
- **THEN** 页面以列表形式逐行显示，每行只显示行号和 TTS 播放按钮

#### Scenario: 内容只有一行
- **WHEN** 文章content只包含一行文本
- **THEN** 页面显示一行，包含行号和 TTS 播放按钮

### Requirement: 展开查看原文
每行必须提供展开/折叠控件，用于控制原文的显示和隐藏。

#### Scenario: 点击展开显示原文
- **WHEN** 用户点击某行的展开控件
- **THEN** 在该行下方显示原文文本，控件状态变为"已展开"

#### Scenario: 点击折叠隐藏原文
- **WHEN** 用户点击某行的折叠控件
- **THEN** 隐藏该行的原文文本，控件状态恢复为"已折叠"

#### Scenario: 多行独立控制
- **WHEN** 用户同时展开多行原文
- **THEN** 每行的展开状态独立控制，互不影响

### Requirement: 原文可选中
展开后的原文必须支持文本选中操作。

#### Scenario: 原文可选中
- **WHEN** 用户展开原文后在原文区域长按或拖动选择文本
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
- **THEN** 系统打开 Anki 的添加卡片界面，deck 为 "English"，notetype 为 "@EnListen"
- **AND** Front 字段包含当前行上下文（最多3行上方上下文），当前行的选中部分替换为 `<mark>???</mark>`
- **AND** Back 字段包含选中的原文文本
- **AND** title 字段包含当前文章的标题
- **AND** url 字段包含当前文章的 URL（若文章无 URL 则为空字符串）

#### Scenario: AnkiConnect 不可用
- **WHEN** 用户点击提取按钮但 AnkiConnect 服务不可用
- **THEN** 系统显示错误提示 "Cannot connect to Anki. Is Anki running?"

### Requirement: 页面布局和交互
听力练习页面必须提供清晰的布局和流畅的交互体验。

#### Scenario: 页面可滚动
- **WHEN** 文章内容超过屏幕显示范围
- **THEN** 页面支持垂直滚动查看所有内容

#### Scenario: 展开/收起动画
- **WHEN** 用户切换原文显示状态
- **THEN** 原文区域有平滑的展开/收起动画效果
