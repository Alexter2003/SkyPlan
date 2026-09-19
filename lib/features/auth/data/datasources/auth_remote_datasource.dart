import '../../../../core/network/api_client.dart';
import '../models/auth_user_model.dart';
import '../models/session_model.dart';

/// Llamadas HTTP de autenticación y registro.
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<AuthUserModel> register({
    required String email,
    required String username,
    required String password,
    required String passwordConfirmation,
  }) async {
    final envelope = await _client.postJson('/users', {
      'email': email,
      'username': username,
      'password': password,
      'passwordConfirmation': passwordConfirmation,
    });
    return AuthUserModel.fromJson(envelope.dataObject);
  }

  Future<AuthUserModel> confirmEmail({
    required String email,
    required String code,
  }) async {
    final envelope = await _client.postJson('/users/confirm-email', {
      'email': email,
      'code': code,
    });
    return AuthUserModel.fromJson(envelope.dataObject);
  }

  Future<void> resendConfirmation({required String email}) {
    return _client.postJson('/users/resend-confirmation', {'email': email});
  }

  Future<SessionModel> login({
    required String identifier,
    required String password,
  }) async {
    final envelope = await _client.postJson('/auth/login', {
      'identifier': identifier,
      'password': password,
    });
    return SessionModel.fromJson(envelope.dataObject);
  }

  Future<void> logout({required String token}) {
    return _client.postJson('/auth/logout', const {}, token: token);
  }
}
