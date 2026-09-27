## Purpose

为练习页面提供键盘快捷键支持，让用户可以通过 `Ctrl+E` 快速触发 Anki 提取操作，提升学习效率。用户选中文本后直接按快捷键即可，无需任何视觉操作栏。

## Technical Decisions

- 使用 `SingleActivator` 而非 `LogicalKeySet` 绑定快捷键。`LogicalKeySet` 存在修饰键状态残留的 bug：按下 Ctrl+E 后若 Ctrl 先松开，后续仅按 Ctrl 也会误触发回调。`SingleActivator` 正确管理 key down/up 生命周期，避免此问题。
- 不使用底部操作栏（PracticeSelectionBar），选中文本后直接 `Ctrl+E` 触发 Anki 提取。复制功能由系统自带的长按/右键复制替代，节省屏幕空间。

## Requirements

### Requirement: Keyboard shortcut for Anki extract
用户在练习页面选中文本后，可以通过键盘快捷键 `Ctrl+E` 触发 Anki 提取操作。快捷键绑定 SHALL 使用 `SingleActivator` 以避免修饰键状态残留问题。

#### Scenario: Shortcut triggers extract when selection exists
- **WHEN** 用户在练习页面选中了一段文本
- **THEN** 用户按下 `Ctrl+E` 后，系统 SHALL 将选中内容发送到 Anki 添加卡片界面

#### Scenario: Shortcut does nothing when no selection
- **WHEN** 用户在练习页面没有选中任何文本
- **THEN** 用户按下 `Ctrl+E` 后，系统 SHALL 不执行任何操作

#### Scenario: Shortcut works across all practice pages
- **WHEN** 用户在 reading、listening、speaking 或 writing 任一练习页面
- **THEN** `Ctrl+E` 快捷键 SHALL 在所有四个练习页面中均可用