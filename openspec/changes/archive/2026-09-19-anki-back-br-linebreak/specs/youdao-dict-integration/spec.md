## MODIFIED Requirements

### Requirement: 释义填入 Anki Back 字段
系统 SHALL 在用户点击 Extract 触发 Anki 添加流程时，自动查询有道词典，并将所有词性及其中文释义填入 Anki 的 Back 字段。多行内容之间必须使用 `<br>` 标签分隔（而非 `\n`），因为 Anki 模板以 HTML 渲染字段内容，`\n` 不会产生换行效果。此规则适用于所有发送到 Anki 的字段内容。

#### Scenario: 查询成功时填入释义
- **WHEN** 用户选中单词并点击 Extract，且有道查询返回结果
- **THEN** Back 字段内容为所有词性释义，格式为每个 `词性 释义` 之间用 `<br>` 分隔（如 `adj. 短暂的；短命的<br>n. 临时物`）

#### Scenario: 查询失败时优雅降级
- **WHEN** 用户选中单词并点击 Extract，但有道查询失败或返回空结果
- **THEN** Back 字段为空，Anki 添加对话框正常弹出，不影响原有流程

#### Scenario: 选中内容非单词
- **WHEN** 用户选中的是一段包含空格的长文本
- **THEN** 仍然尝试查询，若无结果则 Back 为空
