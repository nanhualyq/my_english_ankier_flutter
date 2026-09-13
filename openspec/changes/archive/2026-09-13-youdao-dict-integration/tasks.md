## 1. 数据模型

- [x] 1.1 创建 `lib/models/youdao_dict_result.dart`，包含 `YoudaoDictResult`、`DictEntry`、`Phonetic`、`Example`、`SynonymGroup` 等模型类，验证可通过单元测试构造和访问所有字段

## 2. 有道词典查询服务

- [x] 2.1 创建 `lib/services/youdao_dict_service.dart`，实现 `lookup(String word)` 方法，调用 `https://dict.youdao.com/jsonapi?q=<word>` 并解析 JSON 响应为 `YoudaoDictResult`，验证用 "hello" 查询返回非空结果
- [x] 2.2 处理网络异常和 API 错误（超时、非 200 状态码、解析失败），验证异常情况下返回 null 而非抛出异常

## 3. 集成到 Extract 流程

- [x] 3.1 修改 `reading_practice_page.dart` 的 `_extractSelection()` 方法，在调用 `guiAddCards` 前调用 `YoudaoDictService.lookup()`，将所有词性释义格式化为 Back 字段内容（每行 `词性 释义`），验证选中单词点击 Extract 后 Anki 弹窗的 Back 字段已填充释义
- [x] 3.2 确保查询失败或返回空结果时 Back 字段为空且 Anki 对话框正常弹出，验证断网情况下 Extract 流程不报错

## 4. 测试

- [x] 4.1 为 `YoudaoDictService` 编写单元测试（mock HTTP），覆盖正常响应、空结果、网络异常三种场景，验证所有测试通过
- [x] 4.2 为 `_extractSelection` 集成有道查询的逻辑编写测试，验证 Back 字段内容格式正确
