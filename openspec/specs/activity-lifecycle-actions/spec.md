# activity-lifecycle-actions Specification

## Purpose

Lets the user act on an activity's lifecycle: mark it done as a checklist, cancel it, reactivate it and reschedule it, always validated by the backend.

## Requirements

### Requirement: Complete and uncomplete as a checklist
The system SHALL let the user mark an activity as completed and undo it from a checkbox, and SHALL update the activity in the list from the response without a full reload.

#### Scenario: Mark completed
- **WHEN** the user checks a pending activity
- **THEN** the system completes it, shows it as completed and updates the visit status from the response

#### Scenario: Undo completion
- **WHEN** the user unchecks a completed activity
- **THEN** the system marks it pending again and reflects a reopened visit

#### Scenario: Visit date not reached
- **WHEN** the API refuses because the visit date has not arrived
- **THEN** the checkbox reverts and the API message is shown

### Requirement: Visit checklist with progress
The system SHALL show a checklist of a location's activities with a progress count of completed over total, inside the location's activities screen.

#### Scenario: Progress shown
- **WHEN** a location has 5 activities and 2 are completed
- **THEN** the screen shows "2 of 5" and a progress bar

#### Scenario: Visit auto-closes
- **WHEN** completing an activity returns visit status COMPLETED
- **THEN** the screen reflects the finished visit

### Requirement: Manual cancel with confirmation
The system SHALL ask for confirmation, with an optional reason up to 500 characters, before cancelling a pending activity.

#### Scenario: Confirm cancel
- **WHEN** the user confirms with or without a reason
- **THEN** the activity becomes "cancelled by user" and shows the reason when given

#### Scenario: Dismiss confirmation
- **WHEN** the user dismisses the dialog
- **THEN** nothing is sent

### Requirement: Reactivate cancelled activity
The system SHALL offer reactivation for activities cancelled by the user or the system, and SHALL ask for an extra confirmation when the probability band is red.

#### Scenario: Reactivate with bad weather
- **WHEN** the user reactivates an activity whose band is red
- **THEN** the system asks "the weather is still bad, are you sure?" before calling the API

#### Scenario: Slot taken
- **WHEN** the API responds 409 because another activity occupies the slot
- **THEN** the system shows the message and offers reschedule

#### Scenario: Already ended
- **WHEN** the API responds 400 because the activity already ended
- **THEN** the system offers to reschedule

### Requirement: Reschedule
The system SHALL let the user pick a new date, start time and end time (reusing the activity form's pickers) and send them for server revalidation, replacing the activity with the response.

#### Scenario: Successful reschedule
- **WHEN** the user submits a valid new date and time range
- **THEN** the activity moves, becomes pending and shows its new probability

#### Scenario: Forecast conflict
- **WHEN** the API responds 422 with a forecast explanation
- **THEN** the system shows that message verbatim and keeps the form open

#### Scenario: Schedule conflict
- **WHEN** the API responds 409 for an overlap or another location that day
- **THEN** the system shows the message and keeps the form open

#### Scenario: Client validation
- **WHEN** the start time is not before the end time or the date is in the past
- **THEN** the system shows a field error without calling the API

### Requirement: Available actions per state
The system SHALL offer only the actions valid for each state: pending offers complete, cancel and reschedule; completed offers undo; cancelled states offer reactivate and reschedule.

#### Scenario: Actions by state
- **WHEN** an activity card is shown
- **THEN** only the actions valid for its state are enabled
