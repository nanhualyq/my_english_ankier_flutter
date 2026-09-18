## 1. PracticeLineItem 已学行弱化样式

- [x] 1.1 在 `PracticeLineItem` 中新增 `bool isLearned` 参数（默认 `false`），为 `true` 时将主文本和次文本的 opacity 设为 0.5。验证：传入 `isLearned: true` 的行视觉上明显弱于普通行。
- [x] 1.2 在各练习页面的 `ListView.builder` 中，根据 `lineNumber <= lastLinePosition` 判断并传入 `isLearned` 参数。验证：有进度记录的文章，对应行及之前的行显示弱化样式。

## 2. Anki 提取成功后更新学习位置

- [x] 2.1 在 `ListeningPracticePage` 的 `_extractSelection` 成功后，调用 `SkillProgressDao.updateLastLinePosition(articleId, SkillType.listening, lineNumber)` 更新位置，并更新内存中的 `lastLinePosition` 状态以刷新 UI。验证：提取某行到 Anki 后，该行立即变为弱化样式。
- [x] 2.2 在 `ReadingPracticePage` 的 `_extractSelection` 成功后，同样更新位置和状态。验证：行为一致。
- [x] 2.3 在 `SpeakingPracticePage` 的 `_extractSelection` 成功后，同样更新位置和状态。验证：行为一致。
- [x] 2.4 在 `WritingPracticePage` 的 `_extractSelection` 成功后，同样更新位置和状态。验证：行为一致。

## 3. 初始滚动恢复

- [x] 3.1 在四个练习页面的 `initState` 中，通过 `SkillProgressDao` 读取 `last_line_position`，在首帧后 `jumpTo` 到目标行位置。验证：重新进入有进度记录的文章，页面自动滚动到上次学到的位置。
- [x] 3.2 处理 `last_line_position` 超出文章总行数的情况：滚动到最后一行。验证：手动将数据库值设为大于总行数，进入页面后不报错且定位到末尾。
- [x] 3.3 处理无历史记录的情况（值为 0 或无记录）：保持从头开始。验证：首次进入新文章，页面从第 0 行显示。
