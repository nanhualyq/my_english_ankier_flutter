## Context

四个练习页面（listening、reading、speaking、writing）都使用 `ListView.builder` 逐行显示文章内容。数据库中已有 `skill_progress` 表，包含 `article_id`、`skill_type` 和 `last_line_position` 字段，`SkillProgressDao` 提供了读写方法。目前这些数据仅用于首页进度展示，未用于页面滚动定位。

## Goals / Non-Goals

**Goals:**
- 进入练习页面时自动滚动到上次学习位置
- Anki 提取成功后更新学习位置到数据库
- 已学行弱化样式，突出未学行
- 四个练习页面行为一致

**Non-Goals:**
- 不改变现有的进度百分比计算逻辑
- 不改变 `skill_progress` 表结构
- 不添加跨文章的全局滚动记忆

## Decisions

### 1. 使用 ScrollController + addPostFrameCallback 实现初始滚动

**选择**: 在 `initState` 中创建 `ScrollController`，通过 `addPostFrameCallback` 在首帧渲染后调用 `jumpTo` 滚动到目标位置。

**替代方案**: 使用 `initialScrollIndex` 参数 —— `ListView.builder` 的 `itemExtent` 未固定，无法直接使用 `initialScrollIndex`。

**理由**: `addPostFrameCallback` 确保 ListView 已完成布局后再滚动，避免布局异常。使用 `jumpTo` 而非 `animateTo` 是因为初始滚动不需要动画。

### 2. 在 Anki 提取成功后更新位置

**选择**: 在各练习页面的 `_extractSelection` 方法中，Anki `guiAddCards` 调用成功后，通过 `SkillProgressDao.updateLastLinePosition` 更新当前行号。仅当新行号大于已有值时更新（单调递增）。

**替代方案**: 在滚动时实时更新 —— 无法区分"浏览"和"学习"。

**理由**: 提取到 Anki 代表用户真正"学过"这一行，是更有意义的学习进度信号。

### 3. 已学行弱化样式

**选择**: 在 `PracticeLineItem` 中新增 `bool isLearned` 参数，为 `true` 时将文本 opacity 设为 0.5。判断逻辑：`lineNumber <= lastLinePosition`。

**替代方案**: 使用不同背景色 —— 可能与选中高亮冲突。

**理由**: 降低透明度是最不侵入式的视觉弱化方式，不影响其他交互功能。

### 4. 通过 SkillProgressDao 直接注入

**选择**: 在各练习页面中直接实例化 `SkillProgressDao`（与现有 `AnkiConnectService` 的使用方式一致）。

**替代方案**: 通过 Riverpod provider 注入 —— 更规范但增加改动范围。

**理由**: 保持与现有代码风格一致，不引入额外的架构变更。

## Risks / Trade-offs

- **[Risk]** 初始滚动时 ListView 可能尚未完成所有 item 的布局 → 使用 `jumpTo` 而非 `scrollToIndex`，接受可能的微小偏差
- **[Trade-off]** `last_line_position` 只记录最远位置，如果用户跳着提取（先提取第10行再提取第5行），第5行不会被视为已学 → 可接受，符合"学到最远处"的语义
- **[Trade-off]** 弱化样式依赖内存中的 `lastLinePosition` 状态，页面刷新后通过重新加载恢复 → 可接受
