## Why

在练习页面（listening/speaking/reading/writing）更新学习进度后，返回首页仍然显示旧的进度百分比。根本原因是 `_ProgressRow` 使用 `FutureBuilder` 直接查询数据库，只在 widget 首次创建时执行一次，从练习页面返回后不会重新查询。

## What Changes

- 新增 `skillProgressProvider`，用 Riverpod 管理每篇文章的技能进度数据
- `_ProgressRow` 从 `FutureBuilder` 改为 `ref.watch(skillProgressProvider)`，实现响应式更新
- 练习页面更新进度后，通过 `ref.invalidate` 通知首页刷新
- 移除 `ArticleDetailNotifier` 中冗余的进度管理逻辑（它与新的 provider 存在重叠）

## Capabilities

### New Capabilities
- `skill-progress-sync`: 技能进度的 Riverpod provider 管理，确保进度数据在页面间实时同步

### Modified Capabilities
- `ui-homepage`: 首页进度展示从 `FutureBuilder` 改为 Riverpod provider 驱动

## Impact

- **lib/providers/**: 新增 `skill_progress_provider.dart`
- **lib/widgets/article_card.dart**: `_ProgressRow` 改用 Riverpod provider
- **lib/screens/**: 四个练习页面在更新进度后需要 `ref.invalidate` 通知刷新
- **lib/providers/article_detail_provider.dart**: 可能需要调整以避免与新 provider 逻辑重复
