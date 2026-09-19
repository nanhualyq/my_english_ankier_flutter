## Context

当前听力练习页面（`@EnListen`）和口语练习页面（`@EnSpeak`）创建 Anki 卡片时，只填充 Front 和 Back 两个字段，不查询有道词典。阅读练习页面已经引入了 `YoudaoDictService`，但仅用于将释义填入 Back 字段，未利用已解析的音标数据。

有道词典 API 已集成在项目中（`YoudaoDictService`），返回的 `YoudaoDictResult` 模型已包含 `phonetics` 字段（`List<Phonetic>`），其中每个 `Phonetic` 对象有 `region`（UK/US）和 `text`（音标文本）。当前代码已经能解析音标，只是未在听力和口语场景使用。

参见 proposal.md 了解动机。

## Goals / Non-Goals

**Goals:**
- 听力和口语练习页面创建 Anki 卡片时，自动将音标填入 `Phone` 字段
- 与现有阅读练习页面的有道集成模式保持一致（查询失败时优雅降级）

**Non-Goals:**
- 不修改阅读练习和写作练习页面的 Anki 字段逻辑（它们不涉及 Phone 字段）
- 不修改 `YoudaoDictResult` 模型或 `YoudaoDictService`（音标数据已可用）
- 不在 UI 上显示音标（仅填入 Anki 卡片字段）

## Decisions

### 1. 复用现有 YoudaoDictService，不抽取公共方法

**选择**：在 `ListeningPracticePage` 和 `SpeakingPracticePage` 的 `_extractSelection()` 方法中直接引入 `YoudaoDictService`，复制阅读练习页面的查询模式。

**理由**：
- 听力/口语页面的查询逻辑与阅读页面几乎一致（查询单词 → 取音标 → 填字段）
- 三个页面各自独立，抽取公共方法会增加不必要的抽象层
- 音标的使用方式不同（阅读页面用释义填 Back，听力/口语用音标填 Phone），强行统一会增加复杂度

**替代方案**：抽取一个 `AnkiFieldPopulator` 服务类 — 过度设计，当前只有三个页面各自行调用。

### 2. 音标格式：`UK /xxx/ US /xxx/`

**选择**：将所有可用音标合并为一个字符串，用空格分隔，带地区标识前缀。

**理由**：
- 与 Anki Phone 字段的常见使用方式一致
- 简洁明了，用户一眼能看到英式和美式发音
- 如果只有一种音标（如只有 US），则只显示 `US /xxx/`

### 3. 查询失败不影响现有流程

**选择**：有道查询失败时，Phone 字段为空字符串，Front 和 Back 字段照常填充。

**理由**：
- 与阅读练习页面的降级策略一致
- 用户核心操作是创建卡片，音标是增强信息，不应阻塞主流程

## Risks / Trade-offs

- **[风险] 有道 API 响应变慢** → 设置 5 秒超时（与阅读页面一致），超时后 Phone 为空。用户创建卡片的体验不受影响，只是缺少音标。
- **[风险] 音标数据不完整** → 某些单词可能只有 US 音标没有 UK 音标，或反之。设计上已处理：只显示可用的音标。
