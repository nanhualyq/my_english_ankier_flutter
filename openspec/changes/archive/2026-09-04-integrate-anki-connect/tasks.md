## 1. AnkiConnect 服务层

- [x] 1.1 添加 `http: ^1.2.0` 依赖到 `pubspec.yaml`
- [x] 1.2 创建 `lib/services/anki_connect_service.dart`
- [x] 1.3 实现 `invoke()` 方法：JSON 编码、POST 请求、超时处理、错误解析
- [x] 1.4 实现 `isAvailable()`：调用 `version` action 检测连接
- [x] 1.5 实现 `guiAddCards()`：封装 `guiAddCards` action，接受 deck/model/fields 参数
- [x] 1.6 创建 `AnkiConnectException` 异常类

## 2. 阅读页面集成

- [x] 2.1 在 `reading_practice_page.dart` 中导入 `AnkiConnectService`
- [x] 2.2 将 `_extractSelection()` 改为 async，调用 AnkiConnect
- [x] 2.3 添加连接检测：`isAvailable()` 失败时显示 SnackBar 提示
- [x] 2.4 实现 `_buildFrontField()`：构建含上下文、高亮、时间戳的 HTML，多行间用 `<br>` 换行
- [x] 2.5 调用 `guiAddCards` 预填字段并打开 Anki 添加界面
- [x] 2.6 错误处理：try-catch + SnackBar 显示错误信息

## 3. 验证

- [x] 3.1 `dart analyze` 无错误
- [x] 3.2 `flutter pub get` 依赖安装成功
- [x] 3.3 现有测试用例通过（reading_practice_page_test 18/18）
