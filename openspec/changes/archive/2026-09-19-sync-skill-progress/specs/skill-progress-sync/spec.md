## Purpose

Provides a centralized Riverpod provider for skill progress data, ensuring that progress updates made in any practice page are immediately reflected in all other views (e.g., homepage) without requiring manual refresh.

## ADDED Requirements

### Requirement: Reactive progress provider
The system SHALL provide a Riverpod provider that delivers skill progress data for a given article, and automatically refreshes when the underlying data changes.

#### Scenario: Provider returns current progress
- **WHEN** any widget watches the skill progress provider for an article
- **THEN** the provider returns the latest skill progress from the database

#### Scenario: Provider invalidation triggers refresh
- **WHEN** the skill progress provider for an article is invalidated
- **THEN** all widgets watching that provider re-fetch data from the database and update their display

### Requirement: Progress update with notification
The system SHALL allow any page to update skill progress and notify all dependent widgets to refresh.

#### Scenario: Practice page updates progress
- **WHEN** a practice page saves updated progress to the database
- **THEN** the system invalidates the skill progress provider for that article
- **AND** the homepage (if still in the navigation stack) reflects the updated progress when the user returns

#### Scenario: Multiple skill types independent
- **WHEN** progress for one skill type is updated
- **THEN** only the affected article's progress provider is invalidated
- **AND** other articles' progress displays remain unaffected
