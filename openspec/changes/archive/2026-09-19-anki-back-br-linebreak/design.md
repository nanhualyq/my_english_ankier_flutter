## Context

当前 `YoudaoDictResult.toBackField()` 使用 `join('\n')` 连接各行释义。Front 字段 (`buildAnkiFrontField`) 已经使用 `<br>` 作为行间分隔符。Back 字段需要保持一致。

## Goals / Non-Goals

**Goals:**
- 修复 Back 字段在 Anki 中的换行显示问题
- 建立统一规则：所有 Anki 字段内容中的换行必须使用 `<br>`

**Non-Goals:**
- 不修改已创建的 Anki 卡片（Back 字段已存储在 Anki 数据库中）
- 不修改 Front 字段的格式（已经正确使用 `<br>`）
- 不修改听力/口语练习页面中 Back 字段为选中原文的场景（原文本身不包含多行内容）

## Decisions

### 修改 `toBackField()` 的分隔符

**决策**: 将 `join('\n')` 改为 `join('<br>')`

**理由**: Anki 模板以 HTML 渲染字段内容，`\n` 在 HTML 中不会产生换行。使用 `<br>` 是 HTML 中的标准换行方式，与 Front 字段保持一致。

**替代方案**: 使用 CSS `white-space: pre` — 需要修改 Anki 模板，影响范围更大，不采用。

## Risks / Trade-offs

- **风险**: 如果用户在 Anki 模板中使用了 `white-space: pre` 或类似样式，`<br>` 可能导致双倍换行 → **缓解**: 当前模板未使用此类样式；若有，用户可自行调整模板。
