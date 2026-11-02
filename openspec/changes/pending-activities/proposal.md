# Proposal

## Why

The Pending Activities module is 30% of the final grade and does not exist yet: the drawer item "Pendientes" is disabled and the app cannot complete, cancel, reactivate or reschedule an activity, nor show a completion probability. Worse, `ActivityModel` maps `cancelled_by_system` to `planned`, so system-cancelled activities already look pending today.

## What Changes

- New "Pendientes" screen backed by `GET /activities/upcoming`: every upcoming activity with its location, day forecast, state and probability, refreshed on entry and by pull-to-refresh.
- Combinable filters: date proximity (`days`), location (`visitId`), probability range, and state; sort by date or probability.
- Probability indicator per activity (percentage + green/yellow/red band + icon; neutral "pending validation" when `null`).
- Four visually distinct states: pending, completed, cancelled by user, cancelled by system (with the cancellation reason).
- Checklist: a checkbox on each pending card and a checklist with progress ("2 of 5") inside `VisitActivitiesScreen`, using `complete` / `uncomplete`; `visitStatus` from the response updates the visit without refetching.
- Manual cancel with confirmation and optional reason; reactivate (extra confirmation when the band is RED); reschedule reusing the activity form's date/time and `WeatherConditionSelector` pieces, with server revalidation (409/422 messages shown verbatim).
- Handle the `ACTIVITY_AUTO_CANCELLED` notification: refresh the list and offer reactivate/reschedule.
- **Fix**: model parsing of `cancelled_by_system`; `Activity` gains `probability`, `probabilityBand`, `cancelReason`, `cancelledAt`, `completedAt`.

## Capabilities

### New Capabilities
- `pending-activities-list`: upcoming-activities screen with forecast, filters, sorting, probability indicator, refresh and state differentiation.
- `activity-lifecycle-actions`: complete/uncomplete checklist, manual cancel, reactivate and reschedule, including the visit-level checklist.

### Modified Capabilities
<!-- None: openspec/specs has no existing capabilities. -->

## Impact

- Code: `lib/features/activities/` (entity, model, repository, datasource, use cases, widgets, `VisitActivitiesScreen`), new `lib/features/pending/` (screen, controller, filter widgets), `lib/features/notifications/` (new notification type), `lib/core/routing/app_routes.dart`, `lib/core/navigation/app_drawer.dart`, `lib/core/di/app_providers.dart`.
- API: `GET /activities/upcoming`, `PATCH /activities/:id/{complete,uncomplete,cancel,reactivate,reschedule}` (see `docs/pending-activities.md`, `docs/activities.md`).
- Dependencies: none new.
- Out of scope: cancellation history, arbitrary date-range filters, OS push notifications.
