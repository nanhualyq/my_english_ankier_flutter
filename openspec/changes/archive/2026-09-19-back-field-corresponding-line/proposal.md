## Why

阅读练习和写作练习创建 Anki 卡片时，Back 字段的信息不够丰富。阅读练习在有道词典查询失败时 Back 为空；写作练习的 Back 始终为空。这导致用户在 Anki 复习时缺少上下文信息，不利于记忆。将对应的原文-译文行对填入 Back 字段，可以提供更有价值的上下文辅助。

## What Changes

- **阅读练习**：当有道词典查询返回空结果时，将当前行对应的译文行填入 Back 字段作为兜底。有道查询成功时保持现有行为不变。
- **写作练习**：每次创建卡片时，无条件将当前行对应的原文行填入 Back 字段。

## Capabilities

### New Capabilities

（无新增能力）

### Modified Capabilities

- `ui-reading-practice`：Anki 卡片 Back 字段在有道查询为空时增加兜底逻辑，填入对应的译文行。
- `ui-writing-practice`：Anki 卡片 Back 字段从始终为空改为始终填入对应的原文行。

## Impact

- `lib/screens/reading_practice_page.dart`：修改 `_extractSelection` 方法中 Back 字段的填充逻辑。
- `lib/screens/writing_practice_page.dart`：修改 `_extractSelection` 方法中 Back 字段的填充逻辑。
- 无新增依赖，无 API 变更，无 breaking change。
