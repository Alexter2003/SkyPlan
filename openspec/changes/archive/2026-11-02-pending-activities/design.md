# Design

## Context

- `Activity` has `ActivityState {planned, completed, cancelled}` and only `isViable`; `ActivityModel._parseState` maps unknown names (including `cancelled_by_system`) to `planned`.
- `ActivitiesRepository` supports only list-by-visit, create, update, delete. `ApiClient` has `patchJson` (no query helper; paths are built by string).
- `ActivityCard` has an options sheet (edit/delete) and status badges; `ActivitiesScreen` and `VisitActivitiesScreen` already refresh on notifications and app resume.
- `ViabilityNotificationType` only knows `notViable` / `viableAgain`.
- `ActivityFormScreen` owns time pickers and `WeatherConditionSelector`. See docs `pending-activities.md` and `activities.md`.

## Goals / Non-Goals

**Goals:**
- One shared `Activity` model for both screens so state, probability and actions render identically everywhere.
- Backend remains the source of truth for filters, probability and validation.

**Non-Goals:**
- Computing probability or viability on the client.
- Pagination UI beyond a sensible page size (see decision 6).

## Decisions

1. **Extend `Activity`, don't fork it.** Add `cancelledBySystem` to `ActivityState`, plus `probability`, `ProbabilityBand {green, yellow, red}`, `cancelReason`, `cancelledAt`, `completedAt`. Fixes the parsing bug and keeps `ActivityCard` reusable. Existing tests are updated for the new state.
   - Alternative: separate `PendingActivity` entity duplicating fields. Rejected: drift and two cards.

2. **`UpcomingActivity` wraps `Activity`.** Adds `Visit`-lite (`id`, `name`, `latitude`, `longitude`, `date`, `status`) and `forecast: List<ForecastHour>?`. Lives in the new `lib/features/pending/domain`, which depends on activities' entity (same cross-feature direction already used activities → locations).

3. **Use cases.** In `activities`: `CompleteActivity`, `UncompleteActivity`, `CancelActivity`, `ReactivateActivity`, `RescheduleActivity` (return `Activity` plus `visitStatus` where the API gives it). In `pending`: `GetUpcomingActivities(filters)`. Datasource builds the query string from an `UpcomingFilters` value object (nulls omitted).

4. **State.** `PendingActivitiesController` holds filters + items + per-id busy set; every action replaces the item from the response (docs step 9) and re-sorts only on refetch. Optimistic UI only for the checkbox, with revert on error.

5. **Shared card.** `ActivityCard` gains a probability indicator widget, a 4-state badge/treatment set (colors from `SkyColors` status tokens, icon + text, never color alone) and an action sheet driven by a pure `availableActions(state)` function (testable).

6. **Pagination.** Request `limit=100` (API max) and show a "load more" only if `total` exceeds it; the fine-grained infinite scroll is deferred.

7. **Reschedule UI.** Extract the date/time pickers from the activity form into a reusable widget and present a bottom sheet/screen with them. The weather-condition selector is not shown: reschedule only changes date and time (API body has just those fields); the 422 message explains the forecast conflict.
   - Alternative: reuse the whole form screen. Rejected: it edits other fields and PATCHes a different endpoint.

8. **Checklist in the visit screen.** `VisitActivitiesScreen` shows a checkbox per activity and a `SkyProgressBar` with completed/total, sharing the same complete/uncomplete use cases; the `visitStatus` response updates the header.

9. **Notifications.** Add `ViabilityNotificationType.autoCancelled`, parsed from `ACTIVITY_AUTO_CANCELLED`; the existing `revision` listener refreshes the list. The local notification tap opens Pendientes.

## Risks / Trade-offs

- [Probability filter hides null-probability items] → explicit UI note; state filter remains available.
- [Optimistic checkbox could flicker on 400] → revert plus API message in a snackbar.
- [Changing `ActivityState` touches existing tests/screens] → update in the first task group before new UI.
- [Server clock/timezone (Guatemala) differs from device] → never decide "today" on the client; rely on API errors.
