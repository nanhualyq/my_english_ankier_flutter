## Purpose

Homepage UI for browsing and managing English articles with learning progress display and CRUD operations.

## Requirements

### Requirement: Article list display
The system SHALL display a scrollable list of all articles on the homepage.

#### Scenario: Display articles
- **WHEN** user opens the homepage
- **THEN** system displays all articles sorted by most recently updated first

#### Scenario: Article card content
- **WHEN** an article is displayed in the list
- **THEN** each card shows the article title and a compact single-line row of four skill progress indicators (listening, speaking, reading, writing) with percentage values
- **AND** tapping the listening indicator (🎧) navigates to the listening practice page for that article
- **AND** tapping the speaking indicator (🗣️) navigates to the speaking practice page for that article
- **AND** tapping the reading indicator (📖) navigates to the reading practice page for that article
- **AND** tapping the writing indicator (✍️) navigates to the writing practice page for that article

#### Scenario: Empty state
- **WHEN** no articles exist in the database
- **THEN** system displays an empty state message indicating no articles and prompting user to add one

### Requirement: Add article
The system SHALL allow user to create a new article from the homepage.

#### Scenario: Create new article via FAB
- **WHEN** user taps the floating action button (+)
- **THEN** system creates a new article with default title "未命名文章" and empty content
- **AND** navigates to the article edit page with the new article

### Requirement: Edit article
The system SHALL allow user to edit an existing article's title, content, and translation.

#### Scenario: Open edit page from menu
- **WHEN** user taps "编辑" from the article card's context menu
- **THEN** system navigates to the article edit page with the article's current data loaded

#### Scenario: Edit page fields
- **WHEN** user is on the article edit page
- **THEN** system displays editable fields for: title (single-line text), English content (multi-line text), and Chinese translation (multi-line text, optional)

#### Scenario: Save edits
- **WHEN** user taps save on the edit page
- **THEN** system persists the changes to the database and navigates back to the homepage

### Requirement: Save as (copy article)
The system SHALL allow user to duplicate an article as a new copy.

#### Scenario: Copy article via menu
- **WHEN** user taps "另存为" from the article card's context menu
- **THEN** system creates a new article with the same content and translation
- **AND** appends " 副本" to the original title
- **AND** navigates to the edit page with the new copy

### Requirement: Reset progress
The system SHALL allow user to reset all learning progress for a specific article.

#### Scenario: Reset with confirmation
- **WHEN** user taps "重置进度" from the article card's context menu
- **THEN** system shows a confirmation dialog
- **AND** on confirmation, deletes all skill progress records for that article
- **AND** the article content remains unchanged

### Requirement: Delete article
The system SHALL allow user to delete an article with confirmation.

#### Scenario: Delete with confirmation
- **WHEN** user taps "删除" from the article card's context menu
- **THEN** system shows a confirmation dialog
- **AND** on confirmation, removes the article and all associated skill progress records
- **AND** the article list updates to reflect the deletion
