import '../entities/account_profile.dart';
import '../repositories/auth_repository.dart';

class GetAccountProfile {
  const GetAccountProfile(this._repository);

  final AuthRepository _repository;

  Future<AccountProfile> call() => _repository.getProfile();
}
