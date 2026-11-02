import 'package:sky_plan/core/network/api_exception.dart';
import 'package:sky_plan/features/auth/domain/entities/account_profile.dart';
import 'package:sky_plan/features/auth/domain/entities/auth_user.dart';
import 'package:sky_plan/features/auth/domain/entities/session.dart';
import 'package:sky_plan/features/auth/domain/repositories/auth_repository.dart';

/// Doble de prueba de [AuthRepository] para las pantallas.
class FakeAuthRepository implements AuthRepository {
  Object? registerError;
  Object? confirmEmailError;
  Object? resendConfirmationError;
  Object? loginError;
  Object? forgotPasswordError;
  Object? changePasswordError;
  Object? profileError;

  /// El login devuelve `mustChangePassword = true`.
  bool loginRequiresPasswordChange = false;

  /// `mustChangePassword` que reporta `getProfile`.
  bool profileRequiresPasswordChange = false;

  String? lastForgotPasswordEmail;
  ({String current, String next, String confirm})? lastPasswordChange;
  int getProfileCalls = 0;

  AuthUser _fakeUser({bool emailConfirmed = false}) => AuthUser(
    id: 1,
    email: 'user@example.com',
    username: 'user123',
    emailConfirmed: emailConfirmed,
    createdAt: DateTime(2026, 1, 1),
  );

  @override
  Future<AuthUser> register({
    required String email,
    required String username,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (registerError != null) throw registerError!;
    return _fakeUser();
  }

  @override
  Future<AuthUser> confirmEmail({
    required String email,
    required String code,
  }) async {
    if (confirmEmailError != null) throw confirmEmailError!;
    return _fakeUser(emailConfirmed: true);
  }

  @override
  Future<void> resendConfirmation({required String email}) async {
    if (resendConfirmationError != null) throw resendConfirmationError!;
  }

  @override
  Future<Session> login({
    required String identifier,
    required String password,
  }) async {
    if (loginError != null) throw loginError!;
    return Session(
      token: 'fake-token',
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      mustChangePassword: loginRequiresPasswordChange,
      user: _fakeUser(emailConfirmed: true),
    );
  }

  @override
  Future<void> logout({required String token}) async {}

  @override
  Future<void> forgotPassword({required String email}) async {
    lastForgotPasswordEmail = email;
    if (forgotPasswordError != null) throw forgotPasswordError!;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    lastPasswordChange = (
      current: currentPassword,
      next: newPassword,
      confirm: confirmNewPassword,
    );
    if (changePasswordError != null) throw changePasswordError!;
  }

  @override
  Future<AccountProfile> getProfile() async {
    getProfileCalls++;
    if (profileError != null) throw profileError!;
    return AccountProfile(
      user: _fakeUser(emailConfirmed: true),
      mustChangePassword: profileRequiresPasswordChange,
    );
  }
}

const duplicateEmailError = ApiException(
  status: 409,
  message: 'Ya existe un usuario registrado con ese correo',
);

const invalidCredentialsError = ApiException(
  status: 401,
  message: 'Credenciales inválidas',
);

const unconfirmedEmailError = ApiException(
  status: 403,
  message: 'Debes confirmar tu correo antes de iniciar sesión',
);

const expiredTemporaryPasswordError = ApiException(
  status: 403,
  message: 'La contraseña temporal expiró. Cierra sesión y solicita una nueva',
);

const wrongCurrentPasswordError = ApiException(
  status: 400,
  message: 'La contraseña actual es incorrecta',
);
