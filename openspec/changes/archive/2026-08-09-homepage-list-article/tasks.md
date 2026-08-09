## 1. Backend Support

- [x] 1.1 Add `resetProgressForArticle(int articleId)` method to `SkillProgressDao`
- [x] 1.2 Add `saveAsArticle(Article original)` method to `ArticlesNotifier`

## 2. Widget Components

- [x] 2.1 Create `SkillProgressWidget` — compact single-line row with four skill icons + percentages
- [x] 2.2 Create `ArticleCard` — title + SkillProgressWidget + PopupMenuButton (编辑/另存为/重置进度/删除)
- [x] 2.3 Add confirmation dialogs for "重置进度" and "删除" in ArticleCard

## 3. Screens

- [x] 3.1 Create `ArticleEditPage` — title field, content field (multiline), translation field (multiline), save action
- [x] 3.2 Create `HomePage` — AppBar, article list (ListView of ArticleCard), empty state, FAB (create → edit)
- [x] 3.3 Implement navigation: FAB → new article → edit page; menu → edit page

## 4. Integration

- [x] 4.1 Update `main.dart` — add ProviderScope, replace demo with HomePage
- [x] 4.2 Wire up all CRUD operations (add, edit, save-as, reset-progress, delete) with provider/dao calls

## 5. Polish

- [x] 5.1 Empty state UI when no articles exist
- [x] 5.2 Progress color coding (0% grey, <50% orange, ≥50% green, 100% blue)

## 6. Testing and Validation

- [x] 6.1 Test `SkillProgressDao.resetProgressForArticle()` — verify all skill progress records are deleted for the article
- [x] 6.2 Test `ArticlesNotifier.saveAsArticle()` — verify new article is created with " 副本" suffix, original content copied, new ID assigned
- [x] 6.3 Test `ArticlesNotifier.addArticle()` — verify new article created with "未命名文章" title and returned to edit page
- [x] 6.4 Test article edit flow — verify title, content, translation can be saved and persisted
- [x] 6.5 Test delete confirmation — verify article and progress are removed only after user confirms
- [x] 6.6 Test reset progress confirmation — verify progress is cleared only after user confirms, article remains
- [x] 6.7 Test empty state — verify empty state widget displays when no articles exist
- [x] 6.8 Test article list refresh — verify list updates after add, delete, and save-as operations
