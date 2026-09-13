## Why

目前从阅读页面提取单词发送到 Anki 时，Back 字段为空。用户需要手动在 Anki 中补充释义，流程繁琐。集成有道词典查询可以在提取时自动填充中文释义，大幅减少手动操作。

## What Changes

- 新增 `YoudaoDictService`，通过有道词典 JSON API (`dict.youdao.com/jsonapi`) 查询单词释义，无需 API key
- 新增 `YoudaoDictResult` 数据模型，完整存储有道返回的音标、释义、例句、同义词等信息（当前仅使用释义，模型预留扩展）
- 修改 `_extractSelection()` 流程：在用户点击 Extract 后、发送 Anki 前，自动查询有道并将释义填入 Back 字段
- 查询失败时优雅降级：Back 字段留空，不影响原有流程

## Capabilities

### New Capabilities
- `youdao-dict-integration`: 有道词典查询服务及其与 Anki 卡片创建流程的集成

### Modified Capabilities

## Impact

- 新增文件：`lib/services/youdao_dict_service.dart`、`lib/models/youdao_dict_result.dart`
- 修改文件：`lib/screens/reading_practice_page.dart`（`_extractSelection` 方法）
- 依赖：已有 `http` 包，无需新增依赖
- 有道 JSON API 为公开接口，无需 key，但需联网
