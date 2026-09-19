## ADDED Requirements

### Requirement: 有道查询为空时 Back 字段兜底
在阅读练习页面，当用户选中文本并点击提取按钮时，若有道词典查询返回空结果，系统 SHALL 将当前行对应的译文行填入 Anki 卡片的 Back 字段作为兜底。

#### Scenario: 有道查询成功时保持现有行为
- **WHEN** 用户选中文本并点击提取按钮，且有道词典查询返回有效释义
- **THEN** Back 字段包含有道词典的释义内容，不使用对应译文行兜底

#### Scenario: 有道查询为空且有对应译文行
- **WHEN** 用户选中文本并点击提取按钮，有道词典查询返回空结果，且文章的 translatedContent 中存在与当前行对应的译文行
- **THEN** Back 字段内容为当前行对应的译文行

#### Scenario: 有道查询为空且无对应译文行
- **WHEN** 用户选中文本并点击提取按钮，有道词典查询返回空结果，且文章的 translatedContent 为空或对应行无译文
- **THEN** Back 字段为空
