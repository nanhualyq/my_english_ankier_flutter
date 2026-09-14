## MODIFIED Requirements

### Requirement: 逐行显示文章内容
阅读练习页面必须将文章内容按行分割，并逐行显示原文。页面使用通用的逐行组件实现，支持主文本（原文）显示和可展开的次文本（译文）。

#### Scenario: 正常显示多行内容
- **WHEN** 文章content包含多行文本（以换行符分隔）
- **THEN** 页面以列表形式逐行显示每一行原文

#### Scenario: 内容只有一行
- **WHEN** 文章content只包含一行文本
- **THEN** 页面显示该行原文
