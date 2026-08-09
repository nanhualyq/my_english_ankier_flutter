# Proposal: Homepage Article List

## Summary

Replace the Flutter demo counter page with a functional article list homepage that displays all English articles with their learning progress, and provides operations to add, edit, copy (save-as), reset progress, and delete articles.

## Motivation

The database layer (SQLite + Riverpod providers) is complete, but the app still shows the default Flutter demo counter. Users need a home page to browse, manage, and navigate to their articles.

## Scope

### In Scope
- Article list page displaying all articles
- Each article card shows title and four skill progress indicators (compact, single-line)
- FAB button to create a new article and enter edit mode
- Context menu (⋮) on each card with: Edit, Save As, Reset Progress, Delete
- Edit page for title, English content, and optional Chinese translation
- "Save As" copies the article with " 副本" suffix and enters edit mode
- "Reset Progress" clears all skill progress for the article (with confirmation)
- "Delete" removes the article and all associated progress (with confirmation)
- Empty state display when no articles exist

### Out of Scope
- Search/filter functionality (future iteration)
- Article reordering or sorting options
- Import/export articles
- Batch operations on multiple articles

## Non-goals
- This change does not modify the database schema or existing data models
- This change does not implement the skill training/learning views

## Key Decisions
- Card layout: title + one-line progress indicators only (no date/line count displayed)
- "Save As" automatically adds " 副本" suffix and navigates to edit page
- Edit page scope: title, content, translation only (not progress management)
- New articles created via FAB start with empty title "未命名文章" and go directly to edit page
