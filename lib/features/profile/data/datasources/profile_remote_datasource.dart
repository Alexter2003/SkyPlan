import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/auth_user_model.dart';

/// Llamadas HTTP de `/users/me`.
class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this._client);

  final ApiClient _client;

  Future<AuthUserModel> update({String? firstName, String? lastName}) async {
    final envelope = await _client.putJson('/users/me', {
      'firstName': ?firstName,
      'lastName': ?lastName,
    });
    return AuthUserModel.fromJson(envelope.dataObject);
  }
}
