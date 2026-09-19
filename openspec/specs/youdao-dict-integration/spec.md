## Purpose

提供有道词典查询功能，并集成到 Anki 卡片创建流程中，使用户提取单词时自动填充中文释义到 Anki Back 字段。

## Requirements

### Requirement: 有道词典查询服务
系统 SHALL 提供通过有道词典 JSON API 查询英文单词释义的能力。查询接口为 `https://dict.youdao.com/jsonapi?q=<word>`，无需 API key。

#### Scenario: 查询存在的单词
- **WHEN** 查询单词 "ephemeral"
- **THEN** 返回包含词性（adj. / n.）和中文释义的结果列表

#### Scenario: 查询不存在的单词
- **WHEN** 查询一个有道词典中不存在的词条
- **THEN** 返回空结果，不抛出异常

#### Scenario: 网络不可用
- **WHEN** 网络请求失败或超时
- **THEN** 返回空结果，不抛出异常

### Requirement: 完整数据模型
系统 SHALL 将有道 API 返回的完整数据解析为结构化模型，包括但不限于：音标（英式/美式）、词典释义（词性+中文）、网络释义、双语例句、同近义词、同根词、考试标注。

#### Scenario: 解析完整响应
- **WHEN** 有道 API 返回包含 ec、blng_sents_part、syno、rel_word、web_trans 等字段的 JSON
- **THEN** 所有字段均被解析并存储在结果模型中，当前未使用的字段可为 null

### Requirement: 释义填入 Anki Back 字段
系统 SHALL 在用户点击 Extract 触发 Anki 添加流程时，自动查询有道词典，并将所有词性及其中文释义填入 Anki 的 Back 字段。多行内容之间必须使用 `<br>` 标签分隔（而非 `\n`），因为 Anki 模板以 HTML 渲染字段内容，`\n` 不会产生换行效果。此规则适用于所有发送到 Anki 的字段内容。

#### Scenario: 查询成功时填入释义
- **WHEN** 用户选中单词并点击 Extract，且有道查询返回结果
- **THEN** Back 字段内容为所有词性释义，格式为每个 `词性 释义` 之间用 `<br>` 分隔（如 `adj. 短暂的；短命的<br>n. 临时物`）

#### Scenario: 查询失败时优雅降级
- **WHEN** 用户选中单词并点击 Extract，但有道查询失败或返回空结果
- **THEN** Back 字段为空，Anki 添加对话框正常弹出，不影响原有流程

#### Scenario: 选中内容非单词
- **WHEN** 用户选中的是一段包含空格的长文本
- **THEN** 仍然尝试查询，若无结果则 Back 为空

### Requirement: 音标填入 Anki Phone 字段
系统 SHALL 在听力练习和口语练习页面创建 Anki 卡片时，自动查询有道词典获取音标，并将音标填入 Anki 的 Phone 字段。

#### Scenario: 查询成功时填入音标
- **WHEN** 用户在听力或口语练习页面选中单词并点击 Extract，且有道查询返回音标数据
- **THEN** Phone 字段内容为音标文本，格式为 `UK /xxx/ US /xxx/`（英式和美式都有的情况），或仅有其中一种时只显示一种

#### Scenario: 查询失败时优雅降级
- **WHEN** 用户在听力或口语练习页面选中单词并点击 Extract，但有道查询失败或返回无音标数据
- **THEN** Phone 字段为空，Anki 添加对话框正常弹出，不影响原有 Front/Back 字段填充流程

#### Scenario: 选中内容包含空格的长文本
- **WHEN** 用户选中一段包含空格的长文本
- **THEN** 仍然尝试查询，若无音标结果则 Phone 为空

### Requirement: 听力练习页面集成有道查询
系统 SHALL 在听力练习页面的 Anki 提取流程中引入有道词典查询服务，用于获取音标数据。

#### Scenario: 听力页面提取时查询有道
- **WHEN** 用户在听力练习页面选中内容并触发 Extract 操作
- **THEN** 系统自动调用有道词典查询选中文本，将音标填入 Phone 字段，同时保持 Front 字段（上下文+???）和 Back 字段（选中原文）不变

### Requirement: 口语练习页面集成有道查询
系统 SHALL 在口语练习页面的 Anki 提取流程中引入有道词典查询服务，用于获取音标数据。

#### Scenario: 口语页面提取时查询有道
- **WHEN** 用户在口语练习页面选中内容并触发 Extract 操作
- **THEN** 系统自动调用有道词典查询选中文本，将音标填入 Phone 字段，同时保持 Front 字段（上下文+高亮）和 Back 字段（选中原文）不变
