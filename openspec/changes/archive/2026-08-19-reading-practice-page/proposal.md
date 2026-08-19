## Why

用户需要在阅读文章时能够逐行查看译文，以提高英语学习效率。当前系统只显示文章列表和进度，但没有提供实际的练习界面。需要一个专门的阅读练习页面，让用户能够逐行阅读原文，并按需查看对应译文。

## What Changes

- 新增阅读练习页面（ReadingPracticePage）
- 在文章卡片上添加点击事件，点击阅读技能（📖）进入练习页面
- 练习页面显示文章的每一行原文
- 每行下方提供独立的切换控件（"显示译文"/"收起译文"）
- 译文在新的一行显示，默认隐藏，点击切换显示状态
- 支持收起功能，不记住展开状态，不处理学习进度

## Capabilities

### New Capabilities
- `ui-reading-practice`: 阅读练习页面，支持逐行显示原文和译文的切换功能

### Modified Capabilities
（无需修改现有能力规范）

## Impact

- 新增文件：`lib/screens/reading_practice_page.dart`
- 修改文件：`lib/widgets/article_card.dart`（添加点击事件）
- 无API变更，无依赖变更
- 使用现有的Article模型（content和translatedContent字段）
