## Why

当前添加 Anki 卡片时，只发送了 `Front` 和 `Back` 字段，但 Anki 笔记模板中还定义了 `title` 和 `url` 字段。这导致用户在 Anki 中查看卡片时缺少文章标题和来源链接等上下文信息，降低了学习卡片的参考价值。

## What Changes

- 四个练习页面（listening、reading、speaking、writing）在调用 `guiAddCards` 时，向 `fields` Map 中追加 `title` 和 `url` 字段
- `title` 取自 `widget.article.title`
- `url` 取自 `widget.article.url`（可为空字符串）

## Capabilities

### New Capabilities

- `ui-writing-practice`: 写作练习页面的 Anki 提取能力规格（此前无 spec）

### Modified Capabilities

- `ui-reading-practice`: 添加卡片时增加 title、url 字段
- `ui-listening-practice`: 添加卡片时增加 title、url 字段
- `ui-speaking-practice`: 添加卡片时增加 title、url 字段

## Impact

- 受影响文件：`lib/screens/listening_practice_page.dart`、`lib/screens/reading_practice_page.dart`、`lib/screens/speaking_practice_page.dart`、`lib/screens/writing_practice_page.dart`
- 无 API 或依赖变更
- Anki 笔记模板需已包含 `title` 和 `url` 字段（由用户在 Anki 端配置）
