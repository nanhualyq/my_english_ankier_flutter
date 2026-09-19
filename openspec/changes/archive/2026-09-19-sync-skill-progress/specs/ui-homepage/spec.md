## MODIFIED Requirements

### Requirement: Article list display
The system SHALL display a scrollable list of all articles on the homepage.

#### Scenario: Display articles
- **WHEN** user opens the homepage
- **THEN** system displays all articles sorted by most recently updated first

#### Scenario: Article card content
- **WHEN** an article is displayed in the list
- **THEN** each card shows the article title and a compact single-line row of four skill progress indicators (listening, speaking, reading, writing) with percentage values
- **AND** the progress indicators use a Riverpod provider to reactively display the latest data
- **AND** tapping the listening indicator navigates to the listening practice page for that article
- **AND** tapping the speaking indicator navigates to the speaking practice page for that article
- **AND** tapping the reading indicator navigates to the reading practice page for that article
- **AND** tapping the writing indicator navigates to the writing practice page for that article

#### Scenario: Progress updates after returning from practice
- **WHEN** user completes a practice session and returns to the homepage
- **THEN** the skill progress indicators immediately reflect the updated progress without requiring manual refresh

#### Scenario: Empty state
- **WHEN** no articles exist in the database
- **THEN** system displays an empty state message indicating no articles and prompting user to add one
