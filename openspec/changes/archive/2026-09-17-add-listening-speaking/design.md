## Context

当前应用有阅读（ReadingPracticePage）和写作（WritingPracticePage）两个练习页面，共用 `PracticeLineItem` 组件。该组件支持"主文本始终可见 + 次文本可展开"的模式。现在需要新增听力和口语两个页面，它们的 UI 模式与读写不同：

- 听力：默认只显示 TTS，展开才显示文本
- 口语：文本和 TTS 始终可见，无展开

## Goals / Non-Goals

**Goals:**
- 扩展 `PracticeLineItem` 以支持听/说两种新模式
- 新建听力和口语练习页面，复用现有组件和模式
- 支持将选中内容提取到 Anki，使用对应的 notetype
- 在首页卡片上添加听力和口语的导航入口

**Non-Goals:**
- 不修改现有阅读和写作页面的行为
- 不新增第三方依赖
- 不修改数据库 schema（SkillType 已包含 listening/speaking）

## Decisions

### Decision 1: 扩展 PracticeLineItem 而非新建组件

**选择**: 给 `PracticeLineItem` 新增 3 个可选参数

**替代方案**: 新建 `ListeningLineItem` / `SpeakingLineItem`

**理由**: 选中逻辑、行号显示、展开/折叠动画等都是共通的。通过参数控制行为差异，避免代码重复。新增的参数都有合理默认值，不影响现有调用方。

新增参数：
- `showPrimaryText: bool` (default `true`) — 是否显示主文本。听力模式传 `false`
- `primaryTextExpandable: bool` (default `false`) — 主文本是否可通过展开/折叠控制。听力模式传 `true`
- `trailing: Widget?` (default `null`) — 主文本下方的附加组件。听/说模式传 `TtsPlayButton`

行为矩阵：

| 模式 | showPrimaryText | primaryTextExpandable | trailing | secondaryText |
|------|----------------|----------------------|----------|---------------|
| 阅读 | true | false | null | 译文 |
| 写作 | true | false | null | 原文 |
| 听 | false | true | TtsPlayButton | null |
| 说 | true | false | TtsPlayButton | null |

### Decision 2: Anki Front 字段的 `???` 替换

**选择**: 给 `buildAnkiFrontField` 新增可选参数 `highlightReplacement: String`

**替代方案**: 新建 `buildAnkiFrontFieldWithBlank` 函数

**理由**: 只有一个参数的差异，用可选参数更简洁。传 `'???'` 时选中部分替换为问号，空字符串时使用原文（向后兼容）。

### Decision 3: 听力页面的展开交互

**选择**: 复用现有的 `secondaryText` 展开机制，但反转可见性

**实现**: 听力模式下，`showPrimaryText=false` 隐藏主文本，`primaryTextExpandable=true` 让展开控件控制主文本的显示。展开控件的 label 使用 `secondaryLabel` 参数（传 `'original'`）。

### Decision 4: 口语页面 TTS 按钮布局

**选择**: TTS 按钮在原文下方单独一行左对齐显示

**理由**: 用户确认可以单独显示。行尾放置会与展开箭头冲突（虽然口语不需要展开，但保持视觉一致性）。

## Risks / Trade-offs

- [Risk] PracticeLineItem 参数增多可能使 API 复杂 → Mitigation: 所有新参数都有合理默认值，现有调用方无需改动
- [Risk] 听力模式的展开逻辑复用 secondaryText 机制可能有边界情况 → Mitigation: 仔细测试 showPrimaryText=false + primaryTextExpandable=true 的组合
