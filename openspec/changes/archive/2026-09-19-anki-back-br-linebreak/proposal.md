## Why

Anki 的卡片模板使用 HTML 渲染字段内容，`\n` 换行符在 HTML 中不会显示为换行。当前 Back 字段（来自有道词典释义）使用 `\n` 连接各行释义，导致在 Anki 中所有释义挤在一行显示，影响可读性。Front 字段已经正确使用 `<br>` 换行，Back 字段应保持一致。

## What Changes

- **修改** `YoudaoDictResult.toBackField()` 方法，将释义行之间的 `\n` 替换为 `<br>`，使 Anki 卡片背面的多行释义正确换行显示。
- 建立并记录规则：所有发送到 Anki 的字段内容中，换行必须使用 `<br>` 而非 `\n`，后续新增或修改 Anki 字段时必须遵循此规则。

## Capabilities

### New Capabilities

（无）

### Modified Capabilities

- `youdao-dict-integration`: Back 字段的行分隔符从 `\n` 改为 `<br>`，使 Anki HTML 模板能正确渲染换行。

## Impact

- **代码**: `lib/models/youdao_dict_result.dart` 中的 `toBackField()` 方法
- **Anki 卡片**: 已创建的卡片不受影响（Back 字段已存储），仅影响后续新创建的卡片
- **无依赖变更**: 不涉及外部库或 API 变更
