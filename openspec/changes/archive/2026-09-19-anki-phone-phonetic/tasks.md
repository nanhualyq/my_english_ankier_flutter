## 1. 听力练习页面集成有道词典查询

- [x] 1.1 在 `listening_practice_page.dart` 中引入 `YoudaoDictService` import，并在 `_extractSelection()` 方法中添加有道词典查询逻辑（参考 `reading_practice_page.dart` 的实现），验证：代码编译通过，无 import 错误
- [x] 1.2 将查询到的音标格式化为 `UK /xxx/ US /xxx/` 格式字符串，填入 `guiAddCards` 的 `fields` 参数中的 `Phone` 字段，验证：Anki 添加对话框中 Phone 字段显示正确音标内容
- [x] 1.3 确保查询失败时 Phone 字段为空字符串，Front/Back 字段不受影响，验证：断网或查询无效文本时，Anki 添加对话框正常弹出，Phone 为空

## 2. 口语练习页面集成有道词典查询

- [x] 2.1 在 `speaking_practice_page.dart` 中引入 `YoudaoDictService` import，并在 `_extractSelection()` 方法中添加有道词典查询逻辑（参考 `reading_practice_page.dart` 的实现），验证：代码编译通过，无 import 错误
- [x] 2.2 将查询到的音标格式化为 `UK /xxx/ US /xxx/` 格式字符串，填入 `guiAddCards` 的 `fields` 参数中的 `Phone` 字段，验证：Anki 添加对话框中 Phone 字段显示正确音标内容
- [x] 2.3 确保查询失败时 Phone 字段为空字符串，Front/Back 字段不受影响，验证：断网或查询无效文本时，Anki 添加对话框正常弹出，Phone 为空

## 3. 验证与测试

- [ ] 3.1 手动测试听力页面：选中一个英文单词（如 "ephemeral"），点击 Extract，验证 Anki 添加对话框中 Front 为上下文+???，Back 为选中原文，Phone 为 `UK /ɪˈfemərəl/ US /ɪˈfemərəl/` 格式
- [ ] 3.2 手动测试口语页面：选中一个英文单词，点击 Extract，验证 Anki 添加对话框中 Front 为上下文+高亮，Back 为选中原文，Phone 为音标格式
- [ ] 3.3 手动测试降级场景：选中一段无意义长文本，验证 Phone 为空，卡片创建流程正常
