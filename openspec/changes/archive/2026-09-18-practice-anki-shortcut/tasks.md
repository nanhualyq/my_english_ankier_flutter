## 1. 创建 AnkiShortcutMixin

- [x] 1.1 创建 `lib/widgets/anki_shortcut_mixin.dart` 文件，实现 `AnkiShortcutMixin` mixin，包含抽象成员（`selection`、`onExtractSelection`、`onCopyToClipboard`）和 `buildWithAnkiShortcuts` 方法，验证 mixin 可被正常混入

## 2. 集成到练习页面

- [x] 2.1 修改 `lib/screens/reading_practice_page.dart`，混入 `AnkiShortcutMixin`，实现抽象成员，在 `build` 方法中使用 `buildWithAnkiShortcuts` 包裹 body，验证 `Ctrl+E` 可触发提取
- [x] 2.2 修改 `lib/screens/listening_practice_page.dart`，同上步骤，验证快捷键可用
- [x] 2.3 修改 `lib/screens/speaking_practice_page.dart`，同上步骤，验证快捷键可用
- [x] 2.4 修改 `lib/screens/writing_practice_page.dart`，同上步骤，验证快捷键可用

## 3. 更新 UI 提示

- [x] 3.1 修改 `lib/widgets/practice_selection_bar.dart`，将 Extract 按钮的 tooltip 从 `'Extract'` 改为 `'Extract (Ctrl+E)'`，验证 tooltip 显示正确

## 4. 测试验证

- [ ] 4.1 手动测试：在任意练习页面选中文本，按 `Ctrl+E`，验证 Anki 添加卡片对话框打开
- [ ] 4.2 手动测试：在没有选中文本时按 `Ctrl+E`，验证无任何操作
- [ ] 4.3 手动测试：验证四个练习页面的 `Ctrl+E` 快捷键均可用
