## 1. 创建阅读练习页面基础结构

- [x] 1.1 创建`lib/screens/reading_practice_page.dart`文件
- [x] 1.2 实现`ReadingPracticePage`类，接收Article参数
- [x] 1.3 实现页面布局：AppBar显示文章标题，Body显示内容列表

## 2. 实现行组件

- [x] 2.1 创建`ReadingLineItem`组件，接收行号、原文、译文参数
- [x] 2.2 实现原文显示区域
- [x] 2.3 实现译文切换控件（"显示译文"/"收起译文"）
- [x] 2.4 实现译文显示区域，使用`AnimatedSize`实现展开/收起动画
- [x] 2.5 实现译文样式：灰色文本，左侧竖线

## 3. 实现数据解析和处理

- [x] 3.1 在`ReadingPracticePage`中解析article.content为行列表
- [x] 3.2 解析article.translatedContent为译文列表
- [x] 3.3 处理译文行数不匹配的情况（译文少于或等于原文行数）

## 4. 修改文章卡片添加点击事件

- [x] 4.1 修改`ArticleCard`组件，添加onReadingPractice回调参数
- [x] 4.2 在文章卡片上为阅读技能（📖）添加点击事件
- [x] 4.3 修改`HomePage`，实现点击阅读技能后导航到阅读练习页面

## 5. 测试和验证

- [x] 5.1 测试文章内容为空的情况
- [x] 5.2 测试译文为空的情况
- [x] 5.3 测试译文行数少于原文的情况
- [x] 5.4 测试译文行数多于原文的情况
- [x] 5.5 测试展开/收起功能
- [x] 5.6 测试页面滚动性能
