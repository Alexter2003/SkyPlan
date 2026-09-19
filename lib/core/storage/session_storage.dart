import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Sesión persistida: token, expiración y un snapshot del usuario (la API
/// no tiene endpoint `/me`).
class StoredSession {
  const StoredSession({
    required this.token,
    required this.expiresAt,
    required this.username,
    required this.email,
  });

  final String token;
  final DateTime expiresAt;
  final String username;
  final String email;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Guarda el token de sesión en el keychain/keystore del dispositivo.
abstract class SessionStorage {
  Future<void> save(StoredSession session);
  Future<StoredSession?> read();
  Future<void> clear();
}

class SecureSessionStorage implements SessionStorage {
  SecureSessionStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'skyplan.session.token';
  static const _expiresAtKey = 'skyplan.session.expiresAt';
  static const _usernameKey = 'skyplan.session.username';
  static const _emailKey = 'skyplan.session.email';

  @override
  Future<void> save(StoredSession session) async {
    await _storage.write(key: _tokenKey, value: session.token);
    await _storage.write(
      key: _expiresAtKey,
      value: session.expiresAt.toIso8601String(),
    );
    await _storage.write(key: _usernameKey, value: session.username);
    await _storage.write(key: _emailKey, value: session.email);
  }

  @override
  Future<StoredSession?> read() async {
    final token = await _storage.read(key: _tokenKey);
    final expiresAtRaw = await _storage.read(key: _expiresAtKey);
    if (token == null || expiresAtRaw == null) return null;

    final expiresAt = DateTime.tryParse(expiresAtRaw);
    if (expiresAt == null) return null;

    final username = await _storage.read(key: _usernameKey) ?? '';
    final email = await _storage.read(key: _emailKey) ?? '';

    return StoredSession(
      token: token,
      expiresAt: expiresAt,
      username: username,
      email: email,
    );
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiresAtKey);
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _emailKey);
  }
}
