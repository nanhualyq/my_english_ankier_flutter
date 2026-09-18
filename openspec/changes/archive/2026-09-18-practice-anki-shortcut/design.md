## Context

四个练习页面（reading / listening / speaking / writing）的 `_extractSelection()` 逻辑几乎相同，只有 SkillType 和内容来源不同。当前没有键盘快捷键处理，用户必须点击按钮才能触发 Anki 提取。

## Goals / Non-Goals

**Goals:**
- 通过 `Ctrl+E` 快捷键触发 Anki 提取操作
- 在所有四个练习页面中统一实现
- 在 Extract 按钮 tooltip 中显示快捷键提示

**Non-Goals:**
- 不绑定其他快捷键（如 `Ctrl+C` 复制，避免与系统快捷键冲突）
- 不改变现有按钮功能和 UI 布局
- 不支持用户自定义快捷键

## Decisions

### Decision 1: 使用 Mixin 方案实现代码复用

**选择**: 创建 `AnkiShortcutMixin`，四个页面通过 `with` 混入

**替代方案**:
- A) 每个页面独立实现：简单但有代码重复
- C) 在 `PracticeSelectionBar` 组件内实现：组件需要变为有状态，且需要 `Focus` 管理

**理由**: Mixin 方案兼顾代码复用和灵活性。四个页面只需实现抽象成员（`selection`、`onExtractSelection`、`onCopyToClipboard`），无需修改现有 `_extractSelection()` 方法。

### Decision 2: 使用 Flutter CallbackShortcuts API

**选择**: 使用 `CallbackShortcuts` + `Focus(autofocus: true)` 包裹页面 body

**替代方案**:
- `Shortcuts` + `Actions`：更重量级，适合需要可撤销/可重做的场景
- `RawKeyboardListener`：已废弃

**理由**: `CallbackShorttures` 是 Flutter 3.x 推荐的轻量级方案，直接将按键映射到回调函数，适合本场景。

### Decision 3: 快捷键作用域

**选择**: 快捷键在 `_selection != null` 时才生效

**理由**: 没有选区时触发提取没有意义，且可能造成用户困惑。在 `CallbackShortcuts` 的回调中检查 `_selection` 是否为 null。

### Decision 4: Mixin 结构设计

```dart
mixin AnkiShortcutMixin<T extends StatefulWidget> on State<T> {
  // 抽象成员 - 子类必须实现
  SelectedContent? get selection;
  void onExtractSelection();
  void onCopyToClipboard();

  // 提供方法 - 包裹子类的 build 内容
  Widget buildWithAnkiShortcuts({required Widget child}) {
    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyE): () {
          if (selection != null) onExtractSelection();
        },
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}
```

## Risks / Trade-offs

- **[风险] 焦点管理** → 使用 `Focus(autofocus: true)` 确保页面获得焦点。如果未来有输入框等组件，可能需要调整焦点策略。
- **[风险] Mac 平台快捷键** → 当前只绑定 `Ctrl+E`，Mac 用户可能期望 `Cmd+E`。后续可通过 `Platform.isMacOS` 判断扩展。
- **[权衡] 不绑定 Ctrl+C** → 避免覆盖系统复制行为，用户仍需点击 Copy 按钮或使用系统快捷键。
