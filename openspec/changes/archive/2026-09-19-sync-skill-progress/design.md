## Context

当前 `_ProgressRow`（`article_card.dart`）使用 `FutureBuilder` 直接调用 `SkillProgressDao` 查询进度。`FutureBuilder` 只在 widget 首次创建时执行 future，无法响应外部数据变化。项目已全面使用 Riverpod 管理状态（`articlesProvider`、`articleDetailProvider` 等），进度数据也应该纳入同一套体系。

## Goals / Non-Goals

**Goals:**
- 练习页面更新进度后，首页自动显示最新进度
- 遵循项目现有的 Riverpod 状态管理模式
- 改动范围最小化，不影响其他功能

**Non-Goals:**
- 不改变进度数据的存储方式（SQLite `skill_progress` 表不变）
- 不改变 `ArticleDetailProvider` 中供练习页面使用的进度加载逻辑
- 不做实时流式监听（不需要 `Stream`，invalidate + 重新查询即可）

## Decisions

### 1. 使用 `FutureProvider.family` 而非 `StateNotifierProvider`

**选择**: `FutureProvider.family<int, (int, String)>` — 参数为 `(articleId, skillType)`，返回 `lastLinePosition`。

**理由**: 
- 进度数据是只读查询，不需要本地状态修改能力
- `FutureProvider.family` 天然支持参数化，每个 (articleId, skillType) 组合独立缓存
- `ref.invalidate(provider)` 可精确刷新单个 skill 进度

**替代方案**:
- `StateNotifierProvider`: 过重，进度查询不需要本地状态管理
- 单个 `FutureProvider<List<SkillProgress>>` 按 articleId 分组: 也可以，但粒度不如按 skillType 细分精确

### 2. 在练习页面的 `_saveProgress` 中调用 `ref.invalidate`

**选择**: 练习页面在写入数据库后，立即 `ref.invalidate(skillProgressProvider(...))` 通知刷新。

**理由**: 
- 练习页面是 `StatefulWidget`，通过 `ConsumerStatefulWidget` 或在顶层用 `Consumer` 获取 `ref`
- 数据库写入和 provider 刷新在同一处完成，逻辑内聚
- 首页 `FutureBuilder` 替换为 `ref.watch` 后，invalidate 会自动触发重建

**替代方案**: 
- 在 `Navigator.pop` 后由首页 invalidate: 需要首页知道用户去了哪个练习页面，耦合度高
- 使用 `Stream` 监听数据库变化: 过度设计，SQLite 没有原生变更通知

### 3. `_ProgressRow` 改用 `ConsumerWidget` + `ref.watch`

**选择**: `_ProgressRow` 已经是 `ConsumerWidget`，只需将 `FutureBuilder` 替换为多个 `ref.watch(skillProgressProvider(...))` 调用。

**理由**: 
- 改动最小，widget 结构不变
- `ref.watch` 在 provider invalidate 时自动触发重建

## Risks / Trade-offs

- **[Risk]** 练习页面需要 `WidgetRef` 来调用 `ref.invalidate`，当前是 `StatefulWidget` → **Mitigation**: 改为 `ConsumerStatefulWidget`，与项目其他页面模式一致
- **[Risk]** `FutureProvider.family` 的 key 需要小心类型定义 → **Mitigation**: 使用 Dart 3 record `(int, String)` 作为 family 参数，类型安全且简洁
- **[Trade-off]** 不做 Stream 监听，意味着只有主动 invalidate 才刷新 → 对于本场景完全足够，因为进度只在用户操作时更新

## Open Questions

无。
