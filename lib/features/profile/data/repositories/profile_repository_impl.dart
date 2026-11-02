import '../../../auth/domain/entities/auth_user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<AuthUser> update({String? firstName, String? lastName}) {
    return _remote.update(firstName: firstName, lastName: lastName);
  }
}
