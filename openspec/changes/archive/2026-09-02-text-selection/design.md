## Context

当前阅读练习页面使用 Flutter 内置 `Text` widget 显示原文和译文，不支持文本选中。页面结构为 `ReadingPracticePage`（StatelessWidget）包含 `ListView`，每个 `ReadingLineItem`（StatefulWidget）管理自己的译文展开状态。

需要在此基础上增加文本选中、复制和提取能力，同时保持现有功能（译文展开/收起）不变。

## Goals / Non-Goals

**Goals:**
- 原文和译文均支持文本选中
- 选中后底部显示操作栏，提供复制和提取功能
- 选区为替换模式（同一时间只保留一个选区）
- 提供 `SelectedContent` 数据模型，为后续 Anki 集成预留接口

**Non-Goals:**
- 不支持跨行选中
- 不实现 Anki 集成（仅预留数据模型和提取按钮）
- 不支持选区累加（多段选中）
- 不持久化选中状态

## Decisions

### 1. Text → SelectableText

**决策**: 将原文和译文的 `Text` widget 替换为 `SelectableText`

**理由**:
- `SelectableText` 是 Flutter 官方提供的可选中文本组件
- 支持 `onSelectionChanged` 回调，可以捕获选区变化
- 与 `Text` API 高度兼容，替换成本最低
- 不需要额外依赖

**替代方案**:
- `SelectionArea` 包裹整个页面：支持跨行选中，但需求明确不需要跨行，且 `SelectionArea` 的选区回调获取不如 `SelectableText` 直接
- 自定义手势处理 + 绘制选区：复杂度过高，无必要

### 2. 选区状态管理：StatefulWidget + 回调

**决策**: `ReadingPracticePage` 从 `StatelessWidget` 改为 `StatefulWidget`，内部持有 `_selection` 状态，通过回调函数从子组件接收选区变化

**理由**:
- 选区状态是页面级 UI 状态，不需要全局共享
- 子组件（`ReadingLineItem`）通过 `onSelected` 回调向上传递选区信息
- 不需要引入 Riverpod 或其他状态管理（仅 UI 局部状态）
- 底部操作栏作为页面的子组件，可以直接访问 `_selection`

**替代方案**:
- 使用 Riverpod Provider 管理选区：过度设计，选区状态是纯 UI 局部状态
- 在 `ReadingLineItem` 内部管理选区并显示操作栏：会导致多个操作栏同时显示的问题

### 3. SelectedContent 数据模型

**决策**: 创建独立的 `SelectedContent` 类，位于 `lib/models/selected_content.dart`

**理由**:
- 职责清晰：数据模型与 UI 分离
- 为后续 Anki 集成提供干净的数据结构
- 包含完整上下文：行号、完整行文本、选中片段、选区范围、是否译文

**字段设计**:
```dart
class SelectedContent {
  final int lineNumber;      // 行号（1-based）
  final String lineText;     // 完整行原文
  final String selectedText; // 选中片段
  final int start;           // 选区起始
  final int end;             // 选区结束
  final bool isTranslation;  // 是否来自译文
}
```

### 4. 底部浮动栏实现

**决策**: 使用 `Stack` + `Positioned(bottom: 0)` 在页面底部叠加浮动操作栏

**理由**:
- 浮动栏不参与 `ListView` 的滚动，始终固定在底部
- 使用 `Material` + `SafeArea` 确保在不同设备上的正确显示
- 选区为 null 时不渲染，不影响正常布局

**替代方案**:
- `BottomSheet`：会遮挡更多内容，且需要额外的状态管理
- `SnackBar` 长驻显示：不适合承载操作按钮
- 在每行底部显示操作栏：多个操作栏会造成视觉混乱

### 5. 选区过滤逻辑

**决策**: 在 `ReadingLineItem` 中过滤折叠选区（光标点击）和空白选区

**理由**:
- `SelectableText` 的 `onSelectionChanged` 在用户点击（放置光标）时也会触发，此时 `selection.isCollapsed == true`
- 纯空白字符的选区没有实际意义
- 过滤后只在有实际文本选中时才通知父组件

## Risks / Trade-offs

### 风险1: SelectableText 与手势冲突
**问题**: `SelectableText` 的长按选中可能与 `ReadingLineItem` 中其他手势（如译文切换的 `GestureDetector`）冲突
**缓解**: 译文切换按钮使用独立的 `GestureDetector` 区域，与原文文本区域分离，不会产生冲突

### 风险2: 大段文本选中的性能
**问题**: 文章很长时，用户选中大段文本可能影响性能
**缓解**: `SelectableText` 是 Flutter 内置组件，底层使用 `RenderEditable`，性能经过优化。且选区限制在单行内，不会出现超大选区

### Trade-off: 不支持跨行选中
**决策**: 选区限制在单行内
**好处**: 实现简单，每行独立管理选区，状态清晰
**代价**: 用户无法一次选中跨多行的段落
