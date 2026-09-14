## Context

当前阅读练习页面 (`ReadingPracticePage`) 是一个独立的 StatefulWidget，包含所有逻辑：选区管理、Anki 集成、有道查询、UI 渲染。写作练习页面与阅读页面高度相似，主要区别在于：

1. 主显示文本从原文变为译文
2. 次要可展开文本从译文变为原文
3. 不查询有道词典，Back 字段留空

直接复制阅读页面会导致大量重复代码，且后续听说页面也会有同样的问题。

## Goals / Non-Goals

**Goals:**
- 提取公共组件，使阅读和写作页面共享基础设施
- 实现写作练习页面，满足 spec 中定义的所有行为
- 保持阅读页面功能完全不变（行为兼容）
- 为后续听说页面预留复用空间

**Non-Goals:**
- 不实现写作进度追踪（后续统一任务处理）
- 不实现听说页面（仅预留复用接口）
- 不修改 AnkiConnectService 或 YoudaoDictService
- 不修改 SelectedContent 数据模型

## Decisions

### Decision 1: 公共组件提取策略

**选择：** 提取为无状态 Widget + 工具函数，不使用继承

**方案对比：**

| 方案 | 优点 | 缺点 |
|------|------|------|
| A. 继承基类 | 共享状态逻辑 | Dart 单继承，灵活性差 |
| B. 组合无状态组件 | 灵活、可测试、符合 Flutter 惯例 | 需要更多参数传递 |
| C. Mixin | 共享方法 | 与 Widget 生命周期耦合 |

**选择方案 B**，提取三个公共单元：
- `PracticeLineItem` — 通用逐行组件
- `PracticeSelectionBar` — 通用底部选区栏
- `buildAnkiFrontField()` — 工具函数

### Decision 2: 配置传递方式

**选择：** 通过构造函数参数直接传递，不引入配置类

理由：只有 2-3 个差异化参数（主/次文本内容、标签文案），不需要额外的配置抽象。每个页面自己构建 `PracticeLineItem` 的参数即可。

### Decision 3: Anki Front 字段构建

**选择：** 提取为纯函数 `buildAnkiFrontField(String content, SelectedContent selection)`

输入是**完整内容**（原文或译文的全部行）和选区信息，函数内部按行分割、取上下文、构建 HTML。这样阅读和写作页面只需传入不同的 content 即可。

### Decision 4: 首页入口接入方式

**选择：** 复用现有的 `_ProgressRow` 和 `SkillProgressWidget` 模式

- `ArticleCard` 添加 `onWritingPractice` 回调
- `SkillProgressWidget` 添加 `onWritingTap` 参数（已有 ✍️ 图标）
- `HomePage` 添加 `_openWritingPractice` 方法

## Risks / Trade-offs

**[Risk] 公共组件参数过多** → 暂时接受，当前只有 2 个页面使用。如果后续参数继续增长，再考虑引入配置类。

**[Risk] 阅读页面重构可能引入回归** → 通过保持行为完全不变来缓解。重构仅替换内部实现，不改变外部行为。测试用例保持不变。

**[Trade-off] 不使用配置类** → 代码更直接，但阅读和写作页面的 build 方法会有一定的结构相似性。可接受，因为差异点足够明确。
