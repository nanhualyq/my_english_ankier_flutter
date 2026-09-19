## Why

听力练习和口语练习页面创建 Anki 卡片时，不会查询有道词典，因此卡片缺少音标信息。音标对于英语学习者至关重要——尤其是在听力和口语场景下，用户需要知道单词的标准发音。阅读练习页面已经集成了有道词典查询，但仅用于填充 Back 字段的释义，未将音标填入 Anki 的 Phone 字段。

## What Changes

- 听力练习页面（`@EnListen` 模型）创建 Anki 卡片时，自动查询有道词典获取音标，并填入 `Phone` 字段
- 口语练习页面（`@EnSpeak` 模型）创建 Anki 卡片时，同样查询有道词典获取音标，并填入 `Phone` 字段
- 音标格式：`UK /xxx/ US /xxx/`，包含英式和美式音标（如果都有）
- 有道查询失败时优雅降级：Phone 字段为空，不影响原有卡片创建流程

## Capabilities

### New Capabilities
_(无)_

### Modified Capabilities
- `youdao-dict-integration`: 新增需求——音标填入 Anki Phone 字段（当前 spec 仅覆盖 Back 字段释义填充，未涉及 Phone 字段）

## Impact

- **代码文件**：`lib/screens/listening_practice_page.dart`、`lib/screens/speaking_practice_page.dart`（需要引入 `YoudaoDictService` 并在 `_extractSelection` 中查询音标）
- **Spec 文件**：`openspec/specs/youdao-dict-integration/spec.md`（需要新增 Phone 字段相关需求）
- **无新依赖**：`YoudaoDictService` 已存在，无需新增第三方包
- **无破坏性变更**：现有 Anki 卡片字段不变，仅新增 `Phone` 字段
