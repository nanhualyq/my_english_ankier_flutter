## Why

用户在练习页面学习时，如果中途退出再重新进入，页面总是从头开始显示，需要手动滚动到上次学习的位置。这对于长文章来说体验很差，尤其在听力和口语练习中，用户需要反复滚动才能找到上次停下来的地方。

数据库中已经有 `skill_progress` 表记录了每个技能的 `last_line_position`，但目前仅用于进度显示，未用于页面滚动定位。

## What Changes

- 练习页面（听力、阅读、口语、写作）进入时，自动滚动到上次学习的最后位置
- 用户将某行内容提取到 Anki 后，将该行号更新为 `last_line_position`，表示"学到这里"
- 已学行（行号 ≤ `last_line_position`）显示弱化样式，未学行保持正常样式，形成视觉分界
- 首次进入（无历史记录）时，从第 0 行开始（保持现有行为）

## Capabilities

### New Capabilities
- `practice-scroll-position`: 练习页面的滚动位置记忆与恢复功能，覆盖所有四个技能练习页面

### Modified Capabilities

（无修改的现有 capability）

## Impact

- **代码**: 四个练习页面需要在 Anki 提取成功后更新 `last_line_position`；`PracticeLineItem` 需要新增已学行弱化样式
- **数据库**: 无变更，复用现有的 `skill_progress` 表和 `SkillProgressDao`
- **依赖**: 无新增依赖
