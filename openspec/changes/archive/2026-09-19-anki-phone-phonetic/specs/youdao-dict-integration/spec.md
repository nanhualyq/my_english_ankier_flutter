## ADDED Requirements

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
