# Spec Delta

## Purpose

Lets the logged-in user see their account data and edit their personal name, while keeping identity fields (username, email, password) immutable from the app.

## ADDED Requirements

### Requirement: Profile displays account data
The system SHALL show the logged-in user's username, email, first name and last name, loaded from the server when the profile screen opens.

#### Scenario: Profile loads
- **WHEN** the user opens the profile screen
- **THEN** the system requests the current profile and shows username, email, first name and last name

#### Scenario: Names not yet defined
- **WHEN** the server returns `null` for first name or last name
- **THEN** the corresponding field is shown empty and editable

#### Scenario: Profile fails to load
- **WHEN** the profile request fails
- **THEN** the system shows the error message returned by the API and a retry action

### Requirement: Identity fields are read-only
The system SHALL present username and email as non-editable, SHALL NOT offer any password field on the profile screen, and SHALL NOT include `username`, `email` or `password` in profile update requests.

#### Scenario: Read-only fields
- **WHEN** the profile screen is shown
- **THEN** username and email are displayed as read-only and no password input exists

### Requirement: User can edit first and last name
The system SHALL allow editing first name and last name, trimming whitespace, requiring 1 to 100 characters per edited field, and sending only the fields that changed.

#### Scenario: Successful edit
- **WHEN** the user changes the first name to a valid value and saves
- **THEN** the system sends only `firstName`, shows a success message and displays the updated profile

#### Scenario: Invalid field
- **WHEN** the user clears a name field or exceeds 100 characters and saves
- **THEN** the system shows a field error and does not send the request

#### Scenario: Nothing changed
- **WHEN** the user saves without modifying any field
- **THEN** the system does not send a request

#### Scenario: Server rejects the update
- **WHEN** the API responds with an error
- **THEN** the system shows the API message verbatim without discarding the user's input

### Requirement: Profile is reachable from the drawer
The system SHALL enable the "Mi perfil" drawer item and navigate to the profile screen from it.

#### Scenario: Open profile from drawer
- **WHEN** the user taps "Mi perfil"
- **THEN** the profile screen opens
