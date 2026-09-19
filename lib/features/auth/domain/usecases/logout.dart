import '../repositories/auth_repository.dart';

class Logout {
  const Logout(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String token}) {
    return _repository.logout(token: token);
  }
}
