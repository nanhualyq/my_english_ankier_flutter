## Context

阅读练习和写作练习创建 Anki 卡片时，Back 字段的填充逻辑需要调整。当前实现中，阅读练习仅在有道词典查询成功时填充 Back，写作练习始终将 Back 置空。文章的 `content`（原文）和 `translatedContent`（译文）以 `\n` 分割后按行号一一对应。

## Goals / Non-Goals

**Goals:**
- 阅读练习：有道查询为空时，用对应的译文行作为 Back 字段兜底
- 写作练习：始终在 Back 字段填入对应的原文行

**Non-Goals:**
- 不修改有道词典查询逻辑本身
- 不修改 Front 字段的构建方式
- 不修改其他练习页面（听力、口语）的行为
- 不引入新的数据模型或服务

## Decisions

### 1. 获取对应译文/原文行的方式

**决策**：在 `_extractSelection` 方法中，通过 `article.translatedContent` / `article.content` 按换行符分割为行数组，使用 `selection.lineNumber - 1`（因为 `lineNumber` 是 1-based）作为索引获取对应行。

**理由**：文章模型已有 `content` 和 `translatedContent` 字段，按行号对应是现有约定，无需引入新逻辑。

**替代方案**：在 `SelectedContent` 模型中增加对应行文本字段 —— 但增加了模型复杂度，且选择时不一定有对应行信息。

### 2. Back 字段格式

**决策**：直接填入对应的单行文本（译文行或原文行），不拼接。与有道查询成功时 Back 仅包含释义文本的风格一致。

**理由**：Front 已经包含当前行的上下文，Back 只需提供对应的另一语言版本作为参考，无需重复当前行。

### 3. 边界情况处理

**决策**：当对应行不存在（索引越界或 translatedContent/content 为空）时，Back 字段留空，不报错。

**理由**：部分文章可能没有译文或原文行数不匹配，应优雅降级。

## Risks / Trade-offs

- [原文/译文行数不一致] → 取对应行前检查索引是否越界，越界时只填入当前行文本
- [选中的是翻译文本时 lineText 仍是主文本] → `SelectedContent.lineText` 在写作模式下已是译文行，可直接使用；对应原文行需从 `article.content` 按行号获取
