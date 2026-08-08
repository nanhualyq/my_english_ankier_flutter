## Why

The English learning app needs persistent local storage to save articles and track user progress across four skills (listening, speaking, reading, writing). Currently, there is no data persistence - all data is lost when the app closes. This prevents users from continuing their learning journey across sessions.

## What Changes

- Add SQLite database layer using sqflite package
- Create Article model for storing English articles with optional translations
- Create SkillProgress model for tracking learning progress per article and skill type
- Implement CRUD operations for articles and progress tracking
- Store line-based progress (last_line_position) for each skill independently
- Calculate progress percentage based on last_line_position / total_lines

## Capabilities

### New Capabilities

- `data-storage`: SQLite database for persisting articles and skill progress, including models, database operations, and data access layer

### Modified Capabilities

- None (initial implementation)

## Impact

- New dependencies: sqflite, path_provider
- New database layer and models
- Affects app initialization and data persistence
- No breaking changes to existing functionality