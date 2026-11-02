# Tasks

## 1. Activity model and state fix

- [x] 1.1 Add `cancelledBySystem`, `probability`, `ProbabilityBand`, `cancelReason`, `cancelledAt`, `completedAt` to `Activity`/`ActivityModel` and fix state parsing; verify with `activity_models_test.dart` cases for all four states and null probability
- [x] 1.2 Update existing screens/cards that switch on `ActivityState`; verify `flutter test test/features/activities` passes

## 2. Lifecycle use cases and data

- [x] 2.1 Add `complete`, `uncomplete`, `cancel`, `reactivate`, `reschedule` to `ActivitiesRepository`, datasource and impl (returning `visitStatus` when present); verify with datasource/model tests against documented payloads
- [x] 2.2 Add the five use cases and register them in `activities_providers.dart`; verify with use case tests using a fake repository

## 3. Upcoming data and controller

- [x] 3.1 Create `lib/features/pending/` domain (`UpcomingActivity`, `ForecastHour`, `UpcomingFilters`, `GetUpcomingActivities`) and data layer for `GET /activities/upcoming`; verify query-string building and parsing tests
- [x] 3.2 Implement `PendingActivitiesController` (filters, load/refresh, busy ids, replace-from-response, optimistic checkbox with revert); verify controller tests including combined filters and error revert

## 4. Shared UI

- [x] 4.1 Build probability indicator widget (percentage, band color, icon, text, null state) and 4-state treatment; verify widget tests per band and state
- [x] 4.2 Add pure `availableOperations(state)` and the action sheet in the pending activity card (`PendingActivityCard`); verify unit and widget tests for each state
- [x] 4.3 Add cancel dialog (optional reason, 500 chars) and red-band reactivate confirmation; verify widget tests

## 5. Pending screen

- [x] 5.1 Build `PendingActivitiesScreen` with cards (location, forecast summary, state, probability, checkbox), pull-to-refresh, refresh on enter/resume/notification, skeleton/empty/error states; verify widget tests
- [x] 5.2 Build filter bar (days, location, probability range, state, sort) with clear action; route `/pending`, enable "Pendientes" in `AppDrawer`; verify widget tests and updated `app_drawer_test`/`app_routes_test`
- [x] 5.3 Build the reschedule sheet reusing the kit's `SkyDateField`/`SkyTimeField` (the same pickers as the activity form) with 409/422 messages; verify widget and controller tests for success, 409, 422 and client validation

## 6. Visit checklist and notifications

- [x] 6.1 Add checkbox + "x of y" progress bar to `VisitActivitiesScreen` and update visit status from `visitStatus`; verify widget tests
- [x] 6.2 Add `autoCancelled` notification type and open Pendientes on tap; verify notification controller/parsing tests

## 7. Integration

- [x] 7.1 Run `flutter analyze` and `flutter test`; manually verify against the backend: filters combined, complete/uncomplete, cancel, reactivate, reschedule, system-cancel distinction, and every acceptance criterion
