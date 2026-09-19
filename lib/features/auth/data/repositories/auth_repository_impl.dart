import '../../domain/entities/auth_user.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<AuthUser> register({
    required String email,
    required String username,
    required String password,
    required String passwordConfirmation,
  }) {
    return _remote.register(
      email: email,
      username: username,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  @override
  Future<AuthUser> confirmEmail({required String email, required String code}) {
    return _remote.confirmEmail(email: email, code: code);
  }

  @override
  Future<void> resendConfirmation({required String email}) {
    return _remote.resendConfirmation(email: email);
  }

  @override
  Future<Session> login({
    required String identifier,
    required String password,
  }) {
    return _remote.login(identifier: identifier, password: password);
  }

  @override
  Future<void> logout({required String token}) {
    return _remote.logout(token: token);
  }
}
