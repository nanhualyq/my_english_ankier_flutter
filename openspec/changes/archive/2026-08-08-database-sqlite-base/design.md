## Context

The app currently has no data persistence layer. We need to add SQLite storage for English articles and skill progress tracking. The app uses Flutter with Riverpod for state management.

## Goals / Non-Goals

**Goals:**
- Implement SQLite database using sqflite package
- Create data models for Article and SkillProgress
- Provide CRUD operations for articles and progress
- Calculate progress percentages based on line positions
- Integrate with Riverpod for state management

**Non-Goals:**
- No audio file storage (future feature)
- No cloud sync or backup
- No complex query optimization (small dataset: 10-50 articles)
- No user authentication

## Decisions

### 1. Database Package: sqflite

**Decision:** Use sqflite for SQLite implementation.

**Rationale:**
- Most popular and stable Flutter SQLite package
- Simple API suitable for small dataset
- Good documentation and community support
- Meets requirements without over-engineering

**Alternatives Considered:**
- drift: More powerful but overkill for 10-50 articles
- floor: Annotation-based but less flexible
- isar: NoSQL, not suitable for relational data

### 2. Data Model: Two Separate Tables

**Decision:** Use separate `articles` and `skill_progress` tables.

**Rationale:**
- Clean separation of concerns
- Supports independent progress tracking per skill
- Easy to extend with additional skills later
- Maintains referential integrity with foreign keys

**Schema:**
```sql
-- Articles table
CREATE TABLE articles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  translated_content TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Skill progress table
CREATE TABLE skill_progress (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  article_id INTEGER NOT NULL,
  skill_type TEXT NOT NULL,
  last_line_position INTEGER DEFAULT 0,
  UNIQUE(article_id, skill_type),
  FOREIGN KEY (article_id) REFERENCES articles(id) ON DELETE CASCADE
);
```

### 3. Progress Calculation: Line-Based

**Decision:** Calculate progress as `last_line_position / total_lines`.

**Rationale:**
- Simple and intuitive
- Matches user requirement for line-based tracking
- Works for all skill types uniformly
- Easy to calculate and display

### 4. Architecture: Direct Database Access

**Decision:** Use direct database access without repository pattern.

**Rationale:**
- Appropriate for small dataset (10-50 articles)
- Reduces code complexity
- Sufficient for current requirements
- Can refactor to repository pattern later if needed

### 5. State Management: Riverpod Integration

**Decision:** Integrate with Riverpod using StateNotifier pattern.

**Rationale:**
- User already plans to use Riverpod
- Provides reactive state updates
- Easy to test and maintain
- Good separation of concerns

## Risks / Trade-offs

### Risk 1: Performance with Large Datasets
**Risk:** If article count grows beyond 50, queries may become slow.
**Mitigation:** Current design supports up to 50 articles. Can add indexing or migrate to drift if needed.

### Risk 2: No Cloud Backup
**Risk:** Data loss if device is lost or reset.
**Mitigation:** Acceptable for MVP. Can add export/import feature later.

### Risk 3: Manual Progress Updates
**Risk:** User must manually track progress, which may be forgotten.
**Mitigation:** UI should make progress updates intuitive and automatic where possible.

### Trade-off: Simplicity vs Features
**Trade-off:** Chose simpler implementation over feature-rich alternatives.
**Justification:** Appropriate for MVP with small dataset and basic requirements.