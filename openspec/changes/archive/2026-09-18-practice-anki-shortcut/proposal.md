## Why

在练习页面中，用户选中文本后需要点击底部栏的 Extract 按钮才能将内容发送到 Anki。对于高频使用的用户来说，每次都伸手去点按钮比较低效。添加键盘快捷键可以让用户在选中文本后直接按 `Ctrl+E` 触发提取操作，提升学习效率。

## What Changes

- 新增 `AnkiShortcutMixin`，封装键盘快捷键逻辑
- 四个练习页面（reading / listening / speaking / writing）混入该 mixin
- `PracticeSelectionBar` 的 Extract 按钮 tooltip 显示快捷键提示 `Extract (Ctrl+E)`
- 使用 Flutter 的 `CallbackShortcuts` + `Focus` 实现快捷键绑定

## Capabilities

### New Capabilities
- `practice-keyboard-shortcut`: 练习页面键盘快捷键支持，通过 `Ctrl+E` 触发 Anki 提取操作

### Modified Capabilities

（无修改的现有 capability）

## Impact

- **代码文件**：新增 1 个文件（`lib/widgets/anki_shortcut_mixin.dart`），修改 5 个文件
- **UI 变化**：Extract 按钮 tooltip 增加快捷键提示文案
- **依赖**：无新增依赖，使用 Flutter 内置的 `CallbackShortcuts`
- **兼容性**：不影响现有功能，纯增量添加
