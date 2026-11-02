# Design

## Context

- `SessionController` (ChangeNotifier) exposes `SessionStatus {unknown, authenticated, unauthenticated}`; `AuthGate` switches on it. `LoginScreen` ignores `mustChangePassword` (a `TODO`) and does `pushNamedAndRemoveUntil(home)`, which bypasses any gate placed only in `AuthGate`.
- `bootstrap()` rebuilds a `Session` from `StoredSession` with `mustChangePassword: false` hard-coded; the stored snapshot has no flag and no names.
- `ApiClient` already exposes a `unauthorized` stream consumed by `SessionExpiryListener`. It has no `PUT`.
- `AuthUser` has no `firstName`/`lastName`. Docs: `docs/user-management.md`.

## Goals / Non-Goals

**Goals:**
- The pending password change cannot be skipped through any navigation path (login, restart, 403 mid-session, notification tap).
- Reuse existing patterns (stream + listener, Provider controllers, use cases per action).

**Non-Goals:**
- Voluntary password change from profile (backend returns 403 for it).
- Persisting `mustChangePassword` locally; the server is the source of truth.

## Decisions

1. **Gate = state + listener (option C).** Add `SessionStatus.passwordChangeRequired`. `SessionController.establish()` sets it from `Session.mustChangePassword`; `bootstrap()` calls `GET /users/me` and sets it from the response. A `PasswordChangeListener` (modeled on `SessionExpiryListener`) observes the controller and calls `pushNamedAndRemoveUntil(changePassword, (_) => false)` on entering that status. `AuthGate` also renders `ChangePasswordScreen` for that status.
   - Alternative: navigate only after login (misses restart/deep links). Rejected.
   - Alternative: wrap every route in a guard. Rejected: heavy for named-route setup.

2. **403 stream in `ApiClient`.** `passwordChangeRequired` broadcast stream, emitted on a 403 whose message contains "cambiar tu contraseña" for authenticated calls; `SessionController` subscribes (like `unauthorized`) and switches status. Matching on message is fragile but the API offers no error code; centralised in one constant.

3. **`PUT` support.** Add `putJson` to `ApiClient` (same `_send` path).

4. **Bootstrap tolerance.** If `GET /users/me` fails with a network error, keep the stored session as authenticated (offline start); the 403 stream catches a pending change on the first protected call. A 401 follows the existing expiry path.

5. **Layering.** `auth` feature gains `ForgotPassword`, `ChangePassword` use cases and `ForgotPasswordScreen`/`ChangePasswordScreen`. New `profile` feature (`GetProfile`, `UpdateProfile`, `ProfileScreen`, `ProfileController`). `AuthUser` gains nullable names; `SessionController` updates its user after a profile save so the drawer stays current.

6. **Expired temporary password.** `ChangePasswordController` detects 403 "temporal expiró", calls `endSession()` and routes to forgot-password with the message.

7. **Validation.** Reuse/extend `core/utils/validators.dart` and `PasswordRulesChecklist`; client rules mirror the backend but never replace it (API messages are always surfaced).

## Risks / Trade-offs

- [403 message matching breaks if backend text changes] → single constant + unit test using the documented string.
- [Bootstrap adds a network call before home] → splash stays up; timeout and offline fallback per decision 4.
- [Two redirect mechanisms (gate + listener) could double-navigate] → listener only acts on the status transition and ignores if already on the route.
