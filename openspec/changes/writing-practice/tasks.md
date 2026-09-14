## 1. 提取公共组件

- [x] 1.1 创建 `lib/widgets/practice_selection_bar.dart`，从 `ReadingPracticePage` 的 `_SelectionBar` 提取为公共组件，参数包括 `selection`、`onCopy`、`onExtract`、`onDismiss`，验证文件存在且无编译错误
- [x] 1.2 创建 `lib/utils/anki_field_builder.dart`，提取 `buildAnkiFrontField(String content, SelectedContent selection)` 纯函数，逻辑与阅读页面的 `_buildFrontField` 一致，验证文件存在且无编译错误
- [x] 1.3 创建 `lib/widgets/practice_line_item.dart`，从 `ReadingLineItem` 提取为通用组件，参数包括 `lineNumber`、`primaryText`、`secondaryText`、`primaryLabel`、`secondaryLabel`、`onSelected`，验证文件存在且无编译错误

## 2. 重构阅读练习页面

- [x] 2.1 修改 `lib/screens/reading_practice_page.dart`，导入并使用 `PracticeSelectionBar` 替代 `_SelectionBar`，验证阅读页面功能不变
- [x] 2.2 修改 `lib/screens/reading_practice_page.dart`，导入并使用 `buildAnkiFrontField` 替代 `_buildFrontField`，验证 Anki 提取功能不变
- [x] 2.3 修改 `lib/screens/reading_practice_page.dart`，导入并使用 `PracticeLineItem` 替代 `ReadingLineItem`，验证逐行显示和译文切换功能不变

## 3. 实现写作练习页面

- [x] 3.1 创建 `lib/screens/writing_practice_page.dart`，实现基本页面结构：AppBar 显示文章标题，译文为空时显示空状态提示
- [x] 3.2 实现逐行译文显示，使用 `PracticeLineItem` 组件，主文本为译文，次文本为原文，标签为 "Show original" / "Hide original"
- [x] 3.3 实现选区管理，复用 `SelectedContent` 模型，选中译文时 `isTranslation=true`
- [x] 3.4 实现 Anki 提取功能，使用 `buildAnkiFrontField` 构建 Front 字段（传入译文内容），Back 字段为空，不查询有道词典
- [x] 3.5 实现复制功能和底部选区操作栏，使用 `PracticeSelectionBar` 组件

## 4. 接入首页入口

- [x] 4.1 修改 `lib/widgets/article_card.dart`，添加 `onWritingPractice` 回调参数并传递到 `_ProgressRow`
- [x] 4.2 修改 `lib/widgets/skill_progress_widget.dart`，添加 `onWritingTap` 参数并接线到 ✍️ 图标的 `GestureDetector`
- [x] 4.3 修改 `lib/screens/home_page.dart`，添加 `_openWritingPractice` 方法并连接到 `ArticleCard` 的 `onWritingPractice`

## 5. 验证

- [x] 5.1 运行现有测试 `flutter test`，确保所有测试通过，无回归
- [x] 5.2 手动验证写作页面：进入写作页面 → 看到译文逐行显示 → 选中译文片段 → 底部栏显示 → 点击提取 → Anki 打开添加对话框且 Front 包含译文上下文，Back 为空
- [x] 5.3 手动验证阅读页面功能不变：进入阅读页面 → 逐行原文 → 展开译文 → 选中原文 → 提取到 Anki → 有道查询正常
