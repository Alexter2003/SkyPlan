# pending-activities-list Specification

## Purpose

Shows the user every upcoming activity across all locations with its weather, state and completion probability, so they can decide what to do and when.

## Requirements

### Requirement: Upcoming activities listing
The system SHALL list upcoming activities from all of the user's locations, showing for each one its name, location, date, time range, type, state, day forecast and probability.

#### Scenario: List loads
- **WHEN** the user opens the Pendientes screen
- **THEN** the system requests the upcoming activities and shows each with location, forecast summary, state and probability

#### Scenario: Empty list
- **WHEN** no activity matches
- **THEN** the system shows an empty state, and a distinct one when filters are active

#### Scenario: Load fails
- **WHEN** the request fails
- **THEN** the system shows the API message and a retry action

### Requirement: Forecast refresh
The system SHALL refetch the list every time the screen is entered, on pull-to-refresh, when the app resumes, and when a viability notification arrives, and SHALL NOT cache the forecast across sessions.

#### Scenario: Pull to refresh
- **WHEN** the user pulls down the list
- **THEN** the system refetches with the current filters

#### Scenario: Auto-cancel notification
- **WHEN** an `ACTIVITY_AUTO_CANCELLED` or viability notification arrives while the screen is open
- **THEN** the list refreshes silently

### Requirement: Combinable filters and sorting
The system SHALL let the user combine filters for date proximity (next N days), location, probability range and state, and sort by date or probability, applying all active filters in a single request.

#### Scenario: Combined filters
- **WHEN** the user selects "next 7 days", one location and probability 40 or higher
- **THEN** the request carries `days`, `visitId` and `probabilityMin` together and only matching activities are shown

#### Scenario: Clear filters
- **WHEN** the user clears the filters
- **THEN** the full upcoming list is requested again

#### Scenario: Probability filter excludes unknown
- **WHEN** a probability filter is active
- **THEN** activities without a probability are not shown, and the UI states this

### Requirement: Probability indicator
The system SHALL show each activity's probability as a percentage with a color band (green 70+, yellow 40-69, red below 40) and an icon, and SHALL show a neutral "pending validation" indicator when the probability is null.

#### Scenario: Green band
- **WHEN** an activity has probability 80
- **THEN** it shows "80%" with the green band

#### Scenario: No forecast yet
- **WHEN** probability is null
- **THEN** it shows a neutral "pending validation" indicator and never an invented value

#### Scenario: Not color-only
- **WHEN** a band is displayed
- **THEN** it also carries an icon and a text label so it does not rely on color alone

### Requirement: Four distinguishable states
The system SHALL visually distinguish pending, completed, cancelled by the user and cancelled by the system, and SHALL show the cancellation reason when present.

#### Scenario: System cancellation
- **WHEN** an activity is `cancelled_by_system`
- **THEN** it shows a distinct "cancelled by the weather" treatment with its reason, different from user cancellation

#### Scenario: Completed activity
- **WHEN** an activity is completed
- **THEN** it appears as done and offers no cancel or reschedule action

### Requirement: Pending screen is reachable from the drawer
The system SHALL enable the "Pendientes" drawer item and navigate to the screen from it.

#### Scenario: Open from drawer
- **WHEN** the user taps "Pendientes"
- **THEN** the pending activities screen opens
