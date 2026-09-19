## Context

四个练习页面（listening、reading、speaking、writing）在调用 `anki.guiAddCards()` 时，`fields` Map 中只包含 `Front` 和 `Back` 字段。但用户的 Anki 笔记模板（`@Basic`、`@EnListen`、`@EnSpeak`）中还定义了 `title` 和 `url` 字段。由于未传递这些字段，Anki 中的卡片缺少文章标题和来源链接。

`Article` 模型已包含 `title`（必填）和 `url`（可选）属性，数据层无需变更。

## Goals / Non-Goals

**Goals:**
- 在四个练习页面的 Anki 提取操作中，将 `widget.article.title` 和 `widget.article.url` 一并发送到 Anki

**Non-Goals:**
- 不修改 Anki 笔记模板（由用户在 Anki 端自行配置）
- 不修改 `AnkiConnectService` 或 `buildAnkiFrontField` 工具函数
- 不修改 `Article` 数据模型

## Decisions

### 1. 直接在各页面的 `_extractSelection()` 中追加字段

在每个页面的 `guiAddCards` 调用中，向 `fields` Map 追加 `'Title': widget.article.title` 和 `'Url': widget.article.url ?? ''`。

**理由**：这是最简单直接的方式，改动最小，每个页面只需加两行代码。

**替代方案**：抽取公共方法到 `anki_field_builder.dart`。但考虑到各页面的 notetype 不同、Back 字段逻辑不同，抽象反而增加复杂度，暂不采用。

### 2. url 为空时传空字符串

当 `widget.article.url` 为 `null` 时，传空字符串 `''` 而非跳过该字段。

**理由**：AnkiConnect 的 `fields` Map 中传入空字符串会清空该字段，与不传的效果一致。保持代码一致性。

## Risks / Trade-offs

- [风险] 用户的 Anki 笔记模板可能没有 `Title` 或 `url` 字段 → 无影响，AnkiConnect 会忽略不存在的字段名
- [风险] 字段名大小写不匹配（如 Anki 模板中是 `title` 而非 `Title`）→ 需要用户确认 Anki 模板中的实际字段名，当前假设首字母大写
