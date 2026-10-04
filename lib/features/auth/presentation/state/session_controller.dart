// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/session.dart';
import '../../domain/usecases/logout.dart';

enum SessionStatus { unknown, authenticated, unauthenticated }

/// Sesión activa de la app: usuario y token actuales.
class SessionController extends ChangeNotifier {
  SessionController({
    required SessionStorage storage,
    required Logout logout,
    Stream<void>? unauthorized,
  }) : _storage = storage,
       _logout = logout {
    _unauthorizedSub = unauthorized?.listen((_) => expire());
  }

  final SessionStorage _storage;
  final Logout _logout;
  StreamSubscription<void>? _unauthorizedSub;

  SessionStatus status = SessionStatus.unknown;
  Session? session;

  /// `true` cuando la sesión terminó porque el servidor rechazó el token.
  bool expired = false;

  /// Lee la sesión guardada al iniciar la app.
  Future<void> bootstrap() async {
    StoredSession? stored;
    try {
      stored = await _storage.read().timeout(const Duration(seconds: 3));
    } catch (_) {
      stored = null;
    }

    if (stored == null || stored.isExpired) {
      if (stored != null) await _storage.clear();
      status = SessionStatus.unauthenticated;
      notifyListeners();
      return;
    }

    session = Session(
      token: stored.token,
      expiresAt: stored.expiresAt,
      mustChangePassword: false,
      user: AuthUser(
        id: 0,
        email: stored.email,
        username: stored.username,
        emailConfirmed: true,
        createdAt: stored.expiresAt,
      ),
    );
    status = SessionStatus.authenticated;
    notifyListeners();
  }

  Future<void> establish(Session session) async {
    this.session = session;
    status = SessionStatus.authenticated;
    await _storage.save(
      StoredSession(
        token: session.token,
        expiresAt: session.expiresAt,
        username: session.user.username,
        email: session.user.email,
      ),
    );
    notifyListeners();
  }

  Future<void> endSession() async {
    final token = session?.token;
    if (token != null) {
      try {
        await _logout(token: token);
      } catch (_) {
        // Cierre local igual, aunque falle la llamada de red.
      }
    }
    await _storage.clear();
    session = null;
    status = SessionStatus.unauthenticated;
    notifyListeners();
  }

  /// El servidor rechazó el token: limpia la sesión local.
  Future<void> expire() async {
    if (status != SessionStatus.authenticated) return;
    await _storage.clear();
    session = null;
    status = SessionStatus.unauthenticated;
    expired = true;
    notifyListeners();
  }

  void acknowledgeExpiry() => expired = false;

  @override
  void dispose() {
    _unauthorizedSub?.cancel();
    super.dispose();
  }
}
