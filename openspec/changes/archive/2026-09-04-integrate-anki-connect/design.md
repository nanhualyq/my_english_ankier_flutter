## Context

阅读练习页面已有文本选中功能（`SelectedContent` 模型 + `_SelectionBar` 浮动栏），浮动栏上的"Extract"按钮当前仅显示 SnackBar。需要将其接入 AnkiConnect API，实现一键创建闪卡。

AnkiConnect 是 Anki 桌面端的插件，在 `localhost:8765` 运行 HTTP 服务器，接受 JSON-RPC 风格请求。`guiAddCards` action 会打开 Anki 原生的"添加卡片"对话框并预填字段，用户在 Anki 中确认后卡片即创建。

## Goals / Non-Goals

**Goals:**
- 选中文本后点击 Extract，打开 Anki 的添加卡片界面并预填 Front 字段
- Front 字段包含上方3行上下文、当前行（选中部分用 `<mark>` 高亮）、隐藏时间戳
- Back 字段留空，由用户在 Anki 中手动填写
- 连接失败时给出友好提示
- 所有 Anki 参数硬编码（deck、model），后续再做配置化

**Non-Goals:**
- 不实现自动创建卡片（始终通过 Anki GUI 让用户确认）
- 不实现 Anki 连接配置界面
- 不支持移动端（Android/iOS 无法访问 localhost）
- 不实现牌组管理、复习统计等功能
- 不创建自定义 Anki Model

## Decisions

### 1. guiAddCards 而非 addNote

**决策**: 使用 `guiAddCards` 打开 Anki 原生添加界面，而非 `addNote` 静默创建

**理由**:
- 用户需要在 Anki 中填写 Back 字段（翻译/释义）
- Anki 的添加界面已有模型选择、标签编辑、重复检测等成熟功能
- 避免在 Flutter 端重复构建卡片编辑 UI

**替代方案**:
- `addNote` 静默创建：不需要用户交互，但 Back 字段必须预填，不符合"用户填写"的需求
- Flutter 端自建 Preview Dialog：工作量大，且 Anki 原生界面更好用

### 2. AnkiConnectService 独立服务类

**决策**: 创建 `lib/services/anki_connect_service.dart`，封装 HTTP 通信

**理由**:
- 职责单一：只负责与 AnkiConnect 的 HTTP 通信
- 可测试：便于 mock 测试
- 可扩展：后续添加更多 action（如 `deckNames`、`modelFieldNames`）时只需在此类中添加方法
- 不依赖 Flutter framework（纯 Dart HTTP 调用）

### 3. Front 字段 HTML 格式

**决策**: 最多3行上方上下文 + 当前行（`<mark>` 高亮选中部分）+ 隐藏时间戳 `<span>`

**理由**:
- 上下文帮助理解词汇在语境中的含义
- `<mark>` 标签在 Anki 中默认高亮显示，视觉突出
- 隐藏时间戳使每次创建的卡片 Front 内容不同，利用 Anki 的重复检测机制避免完全相同内容的重复卡片（选同一段文本两次，时间戳不同 → 不会被判为重复）

**格式示例**:
```html
The technology has become ubiquitous in modern life.<br>People use it for communication, work, and entertainment.<br>Its impact on society has been profound.<br>The <mark>ubiquitous</mark> nature of smartphones...<span style="display:none">1693800000000</span>
```

### 4. 硬编码参数

**决策**: deck=`English`、model=`@Basic` 全部硬编码

**理由**:
- 最快速实现 MVP
- 减少配置 UI 的工作量
- 后续可通过 `deckNames`、`modelNames` API 拉取用户数据，再做配置界面
- `@Basic` model 是 Anki 默认自带的，所有用户都有

### 5. 连接检测策略

**决策**: 每次点击 Extract 时调用 `isAvailable()`（即 `version` API）检测连接

**理由**:
- Anki 可能随时关闭或重启，不能缓存连接状态
- `version` API 轻量且不需要特殊权限
- 5 秒超时，不会阻塞 UI 过久
- 失败时显示 SnackBar 提示用户启动 Anki
