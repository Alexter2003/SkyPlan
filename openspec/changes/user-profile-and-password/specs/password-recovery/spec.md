# Spec Delta

## Purpose

Lets users who forgot their password obtain a temporary one by email and forces them to replace it with their own password before using any other part of the app.

## ADDED Requirements

### Requirement: Forgot-password request
The system SHALL let an unauthenticated user request a temporary password by entering a registered email, reachable from the login screen, and SHALL always show the same neutral confirmation regardless of whether the email exists.

#### Scenario: Valid email format
- **WHEN** the user submits a well-formed email
- **THEN** the system calls the recovery endpoint and shows "if the email is registered, you will receive a temporary password", including that it expires in 30 minutes and can be requested once every 5 minutes

#### Scenario: Malformed email
- **WHEN** the user submits an empty or malformed email
- **THEN** the system shows a field error and does not send the request

#### Scenario: API error
- **WHEN** the API responds with an error
- **THEN** the system shows the API message

### Requirement: Change-password form with double confirmation
The system SHALL provide a change-password form with current (temporary) password, new password and new-password confirmation, validating on the client that the new password has 8 to 72 characters with at least one lowercase letter, one uppercase letter and one digit, and that both new-password fields match.

#### Scenario: Passwords do not match
- **WHEN** the confirmation differs from the new password
- **THEN** the system shows a mismatch error and does not send the request

#### Scenario: Weak password
- **WHEN** the new password violates the length or character rules
- **THEN** the system shows which rule failed and does not send the request

#### Scenario: Successful change
- **WHEN** the user submits valid values and the API responds 200
- **THEN** the system clears the pending-change state, keeps the same session and continues to the home screen

#### Scenario: Server-side rejection
- **WHEN** the API rejects the change (wrong current password, new equals current)
- **THEN** the system shows the API message and keeps the form values

### Requirement: Mandatory password change after temporary login
The system SHALL redirect to the change-password screen, before any other screen, whenever the session requires a password change, and SHALL NOT allow leaving that screen except by completing the change or logging out.

#### Scenario: Login with temporary password
- **WHEN** login returns `mustChangePassword = true`
- **THEN** the system opens the change-password screen and the user cannot navigate back or to any other screen

#### Scenario: App restarted with pending change
- **WHEN** the app starts with a stored session
- **THEN** the system fetches the profile and, if `mustChangePassword` is true, shows the change-password screen

#### Scenario: Protected endpoint responds pending-change 403
- **WHEN** any authenticated request returns 403 "Debes cambiar tu contraseña antes de continuar"
- **THEN** the system moves to the change-password screen

#### Scenario: Logout stays available
- **WHEN** the change-password screen is shown
- **THEN** the user can log out

### Requirement: Expired temporary password
The system SHALL end the session and send the user to the forgot-password screen with an explanatory message when the change is rejected because the temporary password expired.

#### Scenario: Temporary password expired
- **WHEN** change-password responds 403 "La contraseña temporal expiró..."
- **THEN** the system logs the user out, opens forgot-password and shows the API message
