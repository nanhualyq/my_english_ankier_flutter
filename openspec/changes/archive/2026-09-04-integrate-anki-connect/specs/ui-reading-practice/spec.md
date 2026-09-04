## Purpose

扩展阅读练习页面的"提取"功能，集成 AnkiConnect 插件，实现选中文本后一键发送到 Anki 添加卡片界面。

## Requirements

### Requirement: 提取选中内容到 Anki

用户点击浮动操作栏的"Extract"按钮后，系统必须通过 AnkiConnect API 打开 Anki 的添加卡片对话框，并预填 Front 字段。

#### Scenario: 成功打开 Anki 添加界面
- **WHEN** 用户选中文本并点击"Extract"按钮，且 Anki 已运行且 AnkiConnect 插件已安装
- **THEN** 系统调用 `guiAddCards` API，Anki 打开添加卡片对话框，Front 字段已预填内容，Back 字段为空

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
