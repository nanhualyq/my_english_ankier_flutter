## 1. Setup and Dependencies

- [x] 1.1 Add sqflite and path_provider dependencies to pubspec.yaml
- [x] 1.2 Create database directory structure (lib/database/, lib/models/)
- [x] 1.3 Initialize SQLite database with version and migrations

## 2. Data Models

- [x] 2.1 Create Article model class with all fields (id, title, content, translated_content, timestamps)
- [x] 2.2 Create SkillProgress model class (id, article_id, skill_type, last_line_position)
- [x] 2.3 Create SkillType enum (listening, speaking, reading, writing)
- [x] 2.4 Add model serialization methods (toMap, fromMap)

## 3. Database Operations

- [x] 3.1 Create database initialization and table creation SQL
- [x] 3.2 Implement Article CRUD operations (create, read, update, delete)
- [x] 3.3 Implement SkillProgress CRUD operations
- [x] 3.4 Implement cascade delete for articles and progress
- [x] 3.5 Add progress calculation method (last_line_position / total_lines)

## 4. Riverpod Integration

- [x] 4.1 Create database provider
- [x] 4.2 Create articles StateNotifier with CRUD operations
- [x] 4.3 Create article detail provider with progress calculation
- [x] 4.4 Add progress update methods for each skill type

## 5. Testing and Validation

- [x] 5.1 Test database initialization and table creation
- [x] 5.2 Test article CRUD operations
- [x] 5.3 Test skill progress operations
- [x] 5.4 Test progress percentage calculations
- [x] 5.5 Test cascade delete functionality