# Proposal

## Why

The User module (10% of the final grade) is incomplete: the app has no profile screen, no "forgot password" flow and no change-password screen. `LoginScreen` even carries a `TODO(módulo 2)` where a temporary-password login should redirect. The backend already enforces `mustChangePassword` (403 on every protected route), so without client support a user who recovers their password is locked out.

## What Changes

- Add a profile screen: shows username and email read-only, lets the user edit `firstName` / `lastName` (`GET`/`PUT /users/me`).
- Add a "forgot password" screen reachable from login (`POST /auth/forgot-password`), always showing the neutral backend message.
- Add a change-password screen with new password + confirmation and client-side validation (`PUT /auth/change-password`), using the temporary password as `currentPassword`.
- Make the password change mandatory and unskippable:
  - New `SessionStatus.passwordChangeRequired`; `AuthGate` renders the change-password screen with no way back.
  - `ApiClient` gains `putJson` and a `passwordChangeRequired` stream emitted on the 403 "Debes cambiar tu contraseña..." response; a listener redirects to the change-password screen.
  - `SessionController.bootstrap()` calls `GET /users/me` so `mustChangePassword` survives an app restart.
  - A 403 "temporary password expired" response ends the session and sends the user to forgot-password.
- Extend `AuthUser` with `firstName`, `lastName` (nullable) and enable the "Mi perfil" drawer item.
- Replace the login `TODO` with the real redirect.

## Capabilities

### New Capabilities
- `user-profile`: viewing the logged-in user's data and editing first/last name; username, email and password are never editable.
- `password-recovery`: requesting a temporary password by email and the mandatory, unskippable change-password flow with double confirmation.

### Modified Capabilities
<!-- None: openspec/specs has no existing capabilities. -->

## Impact

- Code: `lib/features/auth/` (entities, models, repository, datasource, use cases, controllers, new screens), new `lib/features/profile/`, `lib/core/network/api_client.dart`, `lib/core/routing/app_routes.dart`, `lib/core/navigation/app_drawer.dart`, `lib/core/di/app_providers.dart`, new navigation listener in `lib/core/navigation/`.
- API: consumes `GET/PUT /users/me`, `POST /auth/forgot-password`, `PUT /auth/change-password` (see `docs/user-management.md`).
- Dependencies: none new.
- Out of scope: changing email or username, voluntary (non-temporary) password change, email-confirmation flow changes.
