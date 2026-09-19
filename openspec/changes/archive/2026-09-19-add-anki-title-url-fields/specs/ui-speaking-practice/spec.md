## MODIFIED Requirements

### Requirement: 提取选中内容到 Anki
用户选中文本后，必须能够将选中内容发送到 Anki 的添加卡片界面。

#### Scenario: 正常提取
- **WHEN** 用户选中一段文本并点击提取按钮
- **THEN** 系统打开 Anki 的添加卡片界面，deck 为 "English"，notetype 为 "@EnSpeak"
- **AND** Front 字段包含当前行上下文（最多3行上方上下文），当前行的选中部分用 `<mark>` 包裹
- **AND** Back 字段包含选中的原文文本
- **AND** title 字段包含当前文章的标题
- **AND** url 字段包含当前文章的 URL（若文章无 URL 则为空字符串）

#### Scenario: AnkiConnect 不可用
- **WHEN** 用户点击提取按钮但 AnkiConnect 服务不可用
- **THEN** 系统显示错误提示 "Cannot connect to Anki. Is Anki running?"
