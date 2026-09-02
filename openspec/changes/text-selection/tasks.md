## 1. 创建 SelectedContent 数据模型

- [x] 1.1 创建 `lib/models/selected_content.dart` 文件
- [x] 1.2 实现 `SelectedContent` 类，包含 lineNumber、lineText、selectedText、start、end、isTranslation 字段
- [x] 1.3 实现 `toString()` 方法用于调试

## 2. 改造 ReadingLineItem 支持文本选中

- [x] 2.1 添加 `onSelected` 回调参数（`ValueChanged<SelectedContent?>`）
- [x] 2.2 将原文区域的 `Text` 替换为 `SelectableText`，绑定 `onSelectionChanged`
- [x] 2.3 将译文区域的 `Text` 替换为 `SelectableText`，绑定 `onSelectionChanged`
- [x] 2.4 实现选区过滤逻辑：过滤折叠选区和空白选区
- [x] 2.5 实现选区安全截取：使用 `clamp` 防止索引越界

## 3. 改造 ReadingPracticePage 为 StatefulWidget

- [x] 3.1 将 `ReadingPracticePage` 从 `StatelessWidget` 改为 `StatefulWidget`
- [x] 3.2 添加 `_selection` 状态（`SelectedContent?`）
- [x] 3.3 实现 `_onContentSelected` 回调方法，更新选区状态
- [x] 3.4 将 `onSelected` 回调传递给 `ReadingLineItem`

## 4. 实现底部浮动操作栏

- [x] 4.1 创建 `_SelectionBar` 私有组件
- [x] 4.2 实现行号标签显示
- [x] 4.3 实现选中文本预览（过长时截断）
- [x] 4.4 实现"复制"按钮：写入剪贴板 + SnackBar 提示
- [x] 4.5 实现"提取"按钮：SnackBar 提示（预留 Anki 接口）
- [x] 4.6 实现"关闭"按钮：清除选区
- [x] 4.7 使用 `Stack` + `Positioned` 将浮动栏固定在页面底部
- [x] 4.8 ListView 底部增加 padding，避免内容被浮动栏遮挡

## 5. 测试和验证

- [x] 5.1 Dart 静态分析通过，无错误
- [x] 5.2 现有测试用例兼容（构造函数签名未变，`find.text()` 兼容 `SelectableText`）
- [x] 5.3 空内容页面功能不受影响
- [x] 5.4 译文展开/收起功能不受影响

## 6. UI 文本英文化

- [x] 6.1 将代码中的中文 UI 字符串替换为英文（按钮 tooltip、SnackBar 提示、空状态文本等）
- [x] 6.2 更新测试中对应的中文文本断言
