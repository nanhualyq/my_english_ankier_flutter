## Context

现有阅读页面 `_extractSelection()` 直接调用 `AnkiConnectService.guiAddCards()`，Back 字段为空。需要在该流程中插入有道词典查询步骤。项目已依赖 `http` 包，可直接用于 HTTP 请求。

## Goals / Non-Goals

**Goals:**
- 在 Extract 流程中自动查询有道词典，将中文释义填入 Anki Back 字段
- 数据模型全面存储有道返回的所有有价值信息（音标、释义、例句等），为后续功能预留
- 查询失败时优雅降级，不影响原有 Anki 添加流程

**Non-Goals:**
- 不做离线词典（如 ECDICT SQLite）
- 不做 UI 展示查询结果（直接填入 Anki）
- 不做音频下载
- 不处理单词变形还原（lemma）

## Decisions

### 1. 数据源：有道词典 JSON API

选择 `https://dict.youdao.com/jsonapi?q=<word>` 而非网页抓取。

**理由：**
- 返回结构化 JSON，无需 HTML 解析
- 无需 API key，无需登录
- 包含 ec（词典释义）、blng_sents_part（例句）、syno（同义词）、rel_word（同根词）等丰富字段

**替代方案：**
- Free Dictionary API：仅英英释义，不满足中文需求
- 有道网页抓取：HTML 结构脆弱，维护成本高
- ECDICT 本地 SQLite：需打包 ~50MB 数据文件，过度设计

### 2. 数据模型：全面存储，按需使用

`YoudaoDictResult` 模型存储有道返回的所有字段。当前仅 `entries`（词性+释义）用于 Back 字段，其他字段（音标、例句、同义词等）保留为可空字段，后续功能直接取用。

**理由：**
- 避免后续功能需要重新查询或修改模型
- 模型与 API 响应解耦，只映射需要的部分

### 3. 集成点：`_extractSelection()` 内部

查询逻辑放在 `_extractSelection()` 方法中，`AnkiConnectService` 之前。

**理由：**
- 触发时机明确：用户点击 Extract 按钮后
- 不影响选中时的性能
- 失败时可直接降级（Back 为空）

### 4. Back 字段格式

```
adj. 短暂的；（主指植物）短生的，短命的
n. 只生存一天的事物；短生植物
```

每行一个 `词性 释义`，所有词性全部列出。

## Risks / Trade-offs

- **[有道 API 稳定性]** → 有道 JSON API 为非官方接口，可能变更或限流。缓解：查询失败时优雅降级，Back 为空。
- **[网络延迟]** → 查询增加 ~200-500ms 延迟。缓解：用户点击 Extract 时才查询，可接受。
- **[选中内容非单词]** → 用户可能选中长文本。缓解：仍尝试查询，有道会返回无结果，Back 为空。
