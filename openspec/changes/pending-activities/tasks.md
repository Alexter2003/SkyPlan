# Tasks

## 1. Activity model and state fix

- [ ] 1.1 Add `cancelledBySystem`, `probability`, `ProbabilityBand`, `cancelReason`, `cancelledAt`, `completedAt` to `Activity`/`ActivityModel` and fix state parsing; verify with `activity_models_test.dart` cases for all four states and null probability
- [ ] 1.2 Update existing screens/cards that switch on `ActivityState`; verify `flutter test test/features/activities` passes

## 2. Lifecycle use cases and data

- [ ] 2.1 Add `complete`, `uncomplete`, `cancel`, `reactivate`, `reschedule` to `ActivitiesRepository`, datasource and impl (returning `visitStatus` when present); verify with datasource/model tests against documented payloads
- [ ] 2.2 Add the five use cases and register them in `activities_providers.dart`; verify with use case tests using a fake repository

## 3. Upcoming data and controller

- [ ] 3.1 Create `lib/features/pending/` domain (`UpcomingActivity`, `ForecastHour`, `UpcomingFilters`, `GetUpcomingActivities`) and data layer for `GET /activities/upcoming`; verify query-string building and parsing tests
- [ ] 3.2 Implement `PendingActivitiesController` (filters, load/refresh, busy ids, replace-from-response, optimistic checkbox with revert); verify controller tests including combined filters and error revert

## 4. Shared UI

- [ ] 4.1 Build probability indicator widget (percentage, band color, icon, text, null state) and 4-state treatment; verify widget tests per band and state
- [ ] 4.2 Add pure `availableActions(state)` and the action sheet in `ActivityCard`; verify unit tests for each state
- [ ] 4.3 Add cancel dialog (optional reason, 500 chars) and red-band reactivate confirmation; verify widget tests

## 5. Pending screen

- [ ] 5.1 Build `PendingActivitiesScreen` with cards (location, forecast summary, state, probability, checkbox), pull-to-refresh, refresh on enter/resume/notification, skeleton/empty/error states; verify widget tests
- [ ] 5.2 Build filter bar (days, location, probability range, state, sort) with clear action; route `/pending`, enable "Pendientes" in `AppDrawer`; verify widget tests and updated `app_drawer_test`/`app_routes_test`
- [ ] 5.3 Extract date/time pickers from the activity form into a reusable widget and build the reschedule flow with 409/422 messages; verify widget tests for success, 409, 422 and client validation

## 6. Visit checklist and notifications

- [ ] 6.1 Add checkbox + "x of y" progress bar to `VisitActivitiesScreen` and update visit status from `visitStatus`; verify widget tests
- [ ] 6.2 Add `autoCancelled` notification type and open Pendientes on tap; verify notification controller/parsing tests

## 7. Integration

- [ ] 7.1 Run `flutter analyze` and `flutter test`; manually verify against the backend: filters combined, complete/uncomplete, cancel, reactivate, reschedule, system-cancel distinction, and every acceptance criterion
