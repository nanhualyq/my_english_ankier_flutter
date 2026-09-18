## Purpose

提供练习页面的滚动位置记忆与恢复功能，让用户在重新进入练习页面时自动回到上次学习的位置，提升长文章学习的连续性体验。

## Requirements

### Requirement: 自动恢复滚动位置
用户进入练习页面时，系统必须自动滚动到该用户上次在该文章、该技能下学习的最后位置。

#### Scenario: 有历史记录时自动滚动
- **WHEN** 用户进入某个练习页面（听力/阅读/口语/写作），且该文章+技能组合在数据库中存在 `last_line_position` 记录（值 > 0）
- **THEN** 页面自动滚动到 `last_line_position` 对应的行位置

#### Scenario: 无历史记录时从头开始
- **WHEN** 用户进入某个练习页面，且该文章+技能组合在数据库中无记录或 `last_line_position` 为 0
- **THEN** 页面从第 0 行开始显示（保持现有行为）

#### Scenario: 记录的行号超出文章总行数
- **WHEN** `last_line_position` 大于或等于文章的总行数（例如文章被编辑缩短后）
- **THEN** 页面滚动到文章的最后一行

### Requirement: 提取到 Anki 后更新学习位置
用户在练习页面中成功将某行内容提取到 Anki 后，系统必须将该行号更新为学习位置。

#### Scenario: 成功提取后更新位置
- **WHEN** 用户选中某行文本并成功发送到 Anki 添加卡片界面
- **THEN** 系统将该行的行号（lineNumber）更新到 `skill_progress.last_line_position`（仅当该行号大于当前值时更新）

#### Scenario: 提取失败时不更新
- **WHEN** 用户尝试提取但 Anki 连接失败或操作取消
- **THEN** 系统不更新 `last_line_position`

### Requirement: 已学行样式弱化
已学习的行（行号 ≤ `last_line_position`）必须在视觉上弱化，使未学行更加突出。

#### Scenario: 已学行显示弱化样式
- **WHEN** 练习页面渲染某行，且该行行号 ≤ 当前 `last_line_position`
- **THEN** 该行的文本颜色降低透明度（例如 opacity 0.5），视觉上弱于未学行

#### Scenario: 未学行保持正常样式
- **WHEN** 练习页面渲染某行，且该行行号 > 当前 `last_line_position`
- **THEN** 该行以正常样式显示（不透明）

#### Scenario: 实时更新样式
- **WHEN** 用户成功提取某行到 Anki 后
- **THEN** 该行及之前的行立即变为弱化样式，无需退出重新进入
