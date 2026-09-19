import '../entities/auth_user.dart';
import '../entities/session.dart';

/// Contrato de autenticación y registro.
abstract class AuthRepository {
  Future<AuthUser> register({
    required String email,
    required String username,
    required String password,
    required String passwordConfirmation,
  });

  Future<AuthUser> confirmEmail({required String email, required String code});

  Future<void> resendConfirmation({required String email});

  Future<Session> login({required String identifier, required String password});

  Future<void> logout({required String token});
}
