## Purpose

SQLite database layer for persisting English articles and tracking user learning progress across four skills (listening, speaking, reading, writing) with line-based progress tracking.

## ADDED Requirements

### Requirement: Article storage
The system SHALL store English articles with title, content, and optional translated content using SQLite database.

#### Scenario: Store article with all fields
- **WHEN** user provides article title, English content, and optional Chinese translation
- **THEN** system stores article with auto-generated ID and timestamps

#### Scenario: Store article without translation
- **WHEN** user provides article title and English content only
- **THEN** system stores article with null translated_content field

### Requirement: Skill progress tracking
The system SHALL track learning progress for each article independently across four skill types: listening, speaking, reading, and writing.

#### Scenario: Create progress record for new article
- **WHEN** new article is created
- **THEN** system creates four skill progress records (listening, speaking, reading, writing) with last_line_position = 0

#### Scenario: Update skill progress
- **WHEN** user learns article content up to specific line number
- **THEN** system updates last_line_position for that skill type

#### Scenario: Independent skill progress
- **WHEN** user progresses in reading skill to line 30
- **AND** user progresses in listening skill to line 15
- **THEN** system maintains separate progress values for each skill

### Requirement: Line-based progress calculation
The system SHALL calculate progress percentage based on last_line_position divided by total lines in article content.

#### Scenario: Calculate progress percentage
- **WHEN** article has 50 total lines
- **AND** user's reading progress is at line 25
- **THEN** progress percentage is 50%

#### Scenario: Empty content handling
- **WHEN** article content is empty or has no lines
- **THEN** progress percentage is 0%

### Requirement: CRUD operations
The system SHALL provide create, read, update, and delete operations for articles and skill progress.

#### Scenario: Create article
- **WHEN** user submits new article data
- **THEN** system creates article and returns article ID

#### Scenario: Read article by ID
- **WHEN** user requests article by ID
- **THEN** system returns article with all fields

#### Scenario: Update article
- **WHEN** user modifies article content or translation
- **THEN** system updates article and timestamp

#### Scenario: Delete article
- **WHEN** user deletes article
- **THEN** system removes article and associated skill progress records

#### Scenario: Get all articles
- **WHEN** user requests article list
- **THEN** system returns all articles with progress percentages

### Requirement: Data integrity
The system SHALL maintain referential integrity between articles and skill progress records.

#### Scenario: Cascade delete
- **WHEN** article is deleted
- **THEN** all associated skill progress records are also deleted

#### Scenario: Prevent orphaned progress
- **WHEN** skill progress record exists
- **THEN** it must reference a valid article ID