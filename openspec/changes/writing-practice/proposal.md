## Why

用户需要一个写作练习页面，与阅读练习页面形成互补。阅读页面显示原文为主、译文为辅；写作页面则反过来，显示译文为主、原文为辅。用户通过选中译文片段来练习翻译，选中内容发送到 Anki 的正面（Front），背面（Back）留空。这为后续的听说练习页面奠定基础。

## What Changes

- 新增写作练习页面 (`WritingPracticePage`)，显示译文为主内容，原文可展开
- 提取阅读页面的公共组件，形成可复用的练习页面基础设施：
  - `PracticeLineItem` — 通用逐行组件（主文本 + 可展开次文本）
  - `PracticeSelectionBar` — 通用底部选区操作栏
  - `buildAnkiFrontField()` — Anki Front 字段 HTML 构建工具函数
- 简化阅读练习页面，引用公共组件
- 在首页文章卡片上添加写作练习入口（✍️ 按钮）
- 写作页面不查询有道词典，Back 字段留空

## Capabilities

### New Capabilities
- `ui-writing-practice`: 写作练习页面的 UI 和交互行为，包括译文显示、文本选中、Anki 集成

### Modified Capabilities
- `ui-reading-practice`: 重构为使用公共组件，功能行为不变，仅实现方式变化
- `ui-homepage`: 添加写作练习入口按钮和导航

## Impact

**新增文件：**
- `lib/screens/writing_practice_page.dart` — 写作练习页面
- `lib/widgets/practice_line_item.dart` — 通用逐行组件
- `lib/widgets/practice_selection_bar.dart` — 通用选区操作栏
- `lib/utils/anki_field_builder.dart` — Anki Front 字段构建工具

**修改文件：**
- `lib/screens/reading_practice_page.dart` — 引用公共组件，移除重复代码
- `lib/widgets/article_card.dart` — 添加 `onWritingPractice` 回调
- `lib/widgets/skill_progress_widget.dart` — 接线 `onWritingTap`
- `lib/screens/home_page.dart` — 添加 `_openWritingPractice` 方法

**依赖关系：**
- 复用现有 `AnkiConnectService`（无变更）
- 复用现有 `SelectedContent` 模型（无变更）
- 不依赖 `YoudaoDictService`（写作页面不查询有道）
