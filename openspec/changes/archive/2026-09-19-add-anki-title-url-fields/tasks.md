## 1. 修改阅读练习页面

- [x] 1.1 在 `lib/screens/reading_practice_page.dart` 的 `_extractSelection()` 方法中，向 `guiAddCards` 的 `fields` Map 追加 `'Title': widget.article.title` 和 `'Url': widget.article.url ?? ''`，并验证编译通过

## 2. 修改听力练习页面

- [x] 2.1 在 `lib/screens/listening_practice_page.dart` 的 `_extractSelection()` 方法中，向 `guiAddCards` 的 `fields` Map 追加 `'Title': widget.article.title` 和 `'Url': widget.article.url ?? ''`，并验证编译通过

## 3. 修改口语练习页面

- [x] 3.1 在 `lib/screens/speaking_practice_page.dart` 的 `_extractSelection()` 方法中，向 `guiAddCards` 的 `fields` Map 追加 `'Title': widget.article.title` 和 `'Url': widget.article.url ?? ''`，并验证编译通过

## 4. 修改写作练习页面

- [x] 4.1 在 `lib/screens/writing_practice_page.dart` 的 `_extractSelection()` 方法中，向 `guiAddCards` 的 `fields` Map 追加 `'Title': widget.article.title` 和 `'Url': widget.article.url ?? ''`，并验证编译通过

## 5. 验证

- [x] 5.1 运行 `flutter analyze` 确认无静态分析错误
- [x] 5.2 运行 `flutter test` 确认所有测试通过
