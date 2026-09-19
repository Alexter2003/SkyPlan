import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  const RegisterUser(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String email,
    required String username,
    required String password,
    required String passwordConfirmation,
  }) {
    return _repository.register(
      email: email,
      username: username,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
