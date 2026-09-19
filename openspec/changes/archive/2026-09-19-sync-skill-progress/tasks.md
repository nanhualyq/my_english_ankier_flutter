## 1. 创建 skill progress provider

- [x] 1.1 新建 `lib/providers/skill_progress_provider.dart`，定义 `skillProgressProvider` 为 `FutureProvider.family<int, (int articleId, String skillType)>`，内部调用 `SkillProgressDao.getSkillProgress` 查询并返回 `lastLinePosition`，验证文件无语法错误
- [x] 1.2 在 provider 文件中添加 `skillProgressListProvider(articleId)` 辅助 provider，返回 `List<SkillProgress>`，供 `_ProgressRow` 整体使用，验证文件无语法错误

## 2. 改造首页进度显示

- [x] 2.1 修改 `lib/widgets/article_card.dart` 的 `_ProgressRow`：将 `FutureBuilder` 替换为 `ref.watch(skillProgressListProvider(articleId))`，保持 UI 外观不变，验证首页正常显示进度
- [x] 2.2 移除 `_ProgressRow` 中不再需要的 `SkillProgressDao` 直接调用和 `FutureBuilder` 代码

## 3. 练习页面 invalidate 通知

- [x] 3.1 修改 `lib/screens/reading_practice_page.dart`：将 `State` 改为 `ConsumerState`，在 `_saveProgress` 中写入数据库后调用 `ref.invalidate(skillProgressListProvider(articleId))`，验证阅读练习保存后返回首页进度更新
- [x] 3.2 修改 `lib/screens/listening_practice_page.dart`：同上模式，验证听力练习保存后返回首页进度更新
- [x] 3.3 修改 `lib/screens/speaking_practice_page.dart`：同上模式，验证口语练习保存后返回首页进度更新
- [x] 3.4 修改 `lib/screens/writing_practice_page.dart`：同上模式，验证写作练习保存后返回首页进度更新

## 4. 验证与清理

- [x] 4.1 运行 `dart fix --apply` 确保无 lint 警告
- [ ] 4.2 手动测试：打开一篇文章的任意练习页面 → 更新进度 → 返回首页 → 确认进度百分比已同步更新
