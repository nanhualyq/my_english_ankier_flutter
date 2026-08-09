# Design: Homepage Article List

## Architecture Overview

```
main.dart (ProviderScope)
  └─ HomePage (ConsumerWidget)
       ├─ articlesProvider → List<Article>
       ├─ ArticleCard (每张卡片)
       │    ├─ 标题
       │    ├─ 四个技能进度（一行紧凑排列）
       │    └─ ⋮ 菜单 → 编辑 / 另存为 / 重置进度 / 删除
       └─ FBA → 创建空文章 → ArticleEditPage
```

## New Files

| File | Purpose |
|------|---------|
| `lib/screens/home_page.dart` | Article list with AppBar, FAB, empty state |
| `lib/screens/article_edit_page.dart` | Edit page for title, content, translation |
| `lib/widgets/article_card.dart` | Card component with title, progress row, menu |
| `lib/widgets/skill_progress_bar.dart` | Compact single-line progress indicator |

## Modified Files

| File | Change |
|------|--------|
| `lib/main.dart` | Add `ProviderScope`, replace demo with `HomePage` |
| `lib/providers/articles_provider.dart` | Add `saveAsArticle()` method |
| `lib/database/skill_progress_dao.dart` | Add `resetProgressForArticle()` method |

## Component Design

### HomePage
- `ConsumerWidget` reading `articlesProvider`
- `Scaffold` with AppBar (title), body (`ListView` of `ArticleCard`), and `FloatingActionButton`
- FAB: creates empty article → navigates to edit page
- Empty state widget when list is empty

### ArticleCard
- `ConsumerWidget` receiving an `Article`
- Displays title and compact progress row
- `PopupMenuButton` for context menu (编辑 / 另存为 / 重置进度 / 删除)
- "重置进度" and "删除" show `AlertDialog` confirmation before executing

### SkillProgressBar
- Compact row: `🎧33%  🗣️50%  📖100%  ✍️0%`
- Each skill shows icon + percentage text
- Color-coded: 0% = grey, <50% = orange, ≥50% = green, 100% = blue

### ArticleEditPage
- `ConsumerWidget` reading article by ID from `articleDetailProvider`
- Three editable fields: title (TextField), content (TextField multiline), translation (TextField multiline)
- AppBar with back button and save action
- Save writes to database via `articlesProvider.updateArticle()`

## Data Flow

### Add Article
```
FAB tap → articlesProvider.addArticle(新Article) → Navigator to ArticleEditPage(newId)
```

### Edit Article
```
Menu "编辑" → Navigator to ArticleEditPage(article.id)
```

### Save As
```
Menu "另存为" → articlesProvider.saveAsArticle(article) → Navigator to ArticleEditPage(newId)
```

### Reset Progress
```
Menu "重置进度" → confirm dialog → skillProgressDao.resetProgressForArticle(articleId) → refresh list
```

### Delete Article
```
Menu "删除" → confirm dialog → articlesProvider.deleteArticle(id) → list refreshes
```

## UI Layout

### Homepage
```
┌──────────────────────────────────────────┐
│ 📚 我的英语文章                           │
├──────────────────────────────────────────┤
│ ┌──────────────────────────────────────┐ │
│ │ Article Title                  [⋮]  │ │
│ │ 🎧33%  🗣️50%  📖100%  ✍️0%          │ │
│ └──────────────────────────────────────┘ │
│                                          │
│                                ┌────┐    │
│                                │ ＋ │    │
│                                └────┘    │
└──────────────────────────────────────────┘
```

### Context Menu
```
┌──────────────────┐
│ ✏️ 编辑            │
│ 📋 另存为          │
│ 🔄 重置进度        │
│ ──────────────── │
│ 🗑️ 删除            │
└──────────────────┘
```

### Edit Page
```
┌──────────────────────────┐
│ ← 编辑文章          💾   │
├──────────────────────────┤
│ 标题                      │
│ [________________________]│
│                          │
│ 英文内容                  │
│ [                        ]│
│ [  多行文本               ]│
│                          │
│ 中文译文（可选）           │
│ [                        ]│
│ [  多行文本               ]│
└──────────────────────────┘
```
