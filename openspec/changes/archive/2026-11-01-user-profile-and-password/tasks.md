# Tasks

## 1. Network and session foundations

- [x] 1.1 Add `putJson` to `ApiClient` and a `passwordChangeRequired` stream emitted on the pending-change 403; verify with new cases in `test/core/network/api_client_test.dart`
- [x] 1.2 Add nullable `firstName`/`lastName` to `AuthUser`/`AuthUserModel`; verify model parsing test
- [x] 1.3 Add `SessionStatus.passwordChangeRequired`; `establish()` sets it from `Session.mustChangePassword`, `SessionController` subscribes to the new stream; verify with a `SessionController` unit test

## 2. Auth data/domain for recovery

- [x] 2.1 Add `forgotPassword`, `changePassword`, `getProfile` to `AuthRepository`, datasource and impl; add `ForgotPassword`, `ChangePassword` use cases and register in `auth_providers.dart`; verify with fake repository tests
- [x] 2.2 `SessionController.bootstrap()` calls `GET /users/me` (offline-tolerant) and sets pending-change status; verify with bootstrap tests (pending, normal, network failure, 401)

## 3. Recovery screens

- [x] 3.1 Build `ForgotPasswordScreen` + controller, add "Olvidé mi contraseña" link on login, route `/forgot-password`; verify widget test (valid, malformed, API error, neutral message)
- [x] 3.2 Build `ChangePasswordScreen` + controller with double confirmation and rules checklist, logout action, no back navigation; verify widget tests (mismatch, weak, success, API error, expired-temporary redirect)
- [x] 3.3 Add `PasswordChangeListener`, route `/change-password`, render it in `AuthGate`, replace the login `TODO`; verify tests for login-with-temporary, restart, and mid-session 403 redirects

## 4. Profile

- [x] 4.1 Create `profile` feature: `UpdateProfile` use case, repository, datasource (`PUT /users/me`), providers; reading reuses auth's `GetAccountProfile` (`GET /users/me`); verify via controller/screen tests
- [x] 4.2 Build `ProfileScreen` + controller (read-only username/email, editable names, diff-only update, error display), route `/profile`, enable "Mi perfil" in `AppDrawer`; verify widget tests and updated `app_drawer_test`/`app_routes_test`
- [x] 4.3 Update session user after a successful profile save so the drawer reflects it; verify via test

## 5. Integration

- [x] 5.1 Run `flutter analyze` and `flutter test`; manually verify the end-to-end recovery flow against the backend (forgot → email → login → forced change → home) and that all acceptance criteria hold
