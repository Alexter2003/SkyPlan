import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class ConfirmEmail {
  const ConfirmEmail(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({required String email, required String code}) {
    return _repository.confirmEmail(email: email, code: code);
  }
}
