## Purpose

为练习页面提供键盘快捷键支持，让用户可以通过 `Ctrl+E` 快速触发 Anki 提取操作，提升学习效率。

## ADDED Requirements

### Requirement: Keyboard shortcut for Anki extract
用户在练习页面选中文本后，可以通过键盘快捷键 `Ctrl+E` 触发 Anki 提取操作，无需点击底部栏的 Extract 按钮。

#### Scenario: Shortcut triggers extract when selection exists
- **WHEN** 用户在练习页面选中了一段文本
- **THEN** 用户按下 `Ctrl+E` 后，系统 SHALL 执行与点击 Extract 按钮相同的操作（发送到 Anki 添加卡片界面）

#### Scenario: Shortcut does nothing when no selection
- **WHEN** 用户在练习页面没有选中任何文本
- **THEN** 用户按下 `Ctrl+E` 后，系统 SHALL 不执行任何操作

#### Scenario: Shortcut works across all practice pages
- **WHEN** 用户在 reading、listening、speaking 或 writing 任一练习页面
- **THEN** `Ctrl+E` 快捷键 SHALL 在所有四个练习页面中均可用

### Requirement: Shortcut visual hint
Extract 按钮的 tooltip 中显示快捷键提示，让用户知道有此功能。

#### Scenario: Tooltip shows shortcut key
- **WHEN** 用户在练习页面选中文本后，底部栏出现
- **THEN** Extract 按钮的 tooltip SHALL 显示 `Extract (Ctrl+E)`
