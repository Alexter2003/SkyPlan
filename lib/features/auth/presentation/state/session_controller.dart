// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/session.dart';
import '../../domain/usecases/get_account_profile.dart';
import '../../domain/usecases/logout.dart';

/// [passwordChangeRequired]: hay sesión, pero el servidor exige cambiar la
/// contraseña temporal antes de permitir cualquier otra cosa.
enum SessionStatus {
  unknown,
  authenticated,
  passwordChangeRequired,
  unauthenticated,
}

/// Sesión activa de la app: usuario y token actuales.
class SessionController extends ChangeNotifier {
  SessionController({
    required SessionStorage storage,
    required Logout logout,
    GetAccountProfile? getProfile,
    Stream<void>? unauthorized,
    Stream<void>? passwordChangeRequired,
  }) : _storage = storage,
       _logout = logout,
       _getProfile = getProfile {
    _unauthorizedSub = unauthorized?.listen((_) => expire());
    _passwordChangeSub = passwordChangeRequired?.listen(
      (_) => requirePasswordChange(),
    );
  }

  final SessionStorage _storage;
  final Logout _logout;
  final GetAccountProfile? _getProfile;
  StreamSubscription<void>? _unauthorizedSub;
  StreamSubscription<void>? _passwordChangeSub;

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
    await _refreshProfile();
    notifyListeners();
  }

  /// Confirma con el servidor el usuario y si hay un cambio pendiente. Sin
  /// red se conserva la sesión guardada: el 403 del backend cubre el resto.
  Future<void> _refreshProfile() async {
    final getProfile = _getProfile;
    final current = session;
    if (getProfile == null || current == null) return;
    try {
      final profile = await getProfile().timeout(const Duration(seconds: 5));
      session = current.copyWith(
        user: profile.user,
        mustChangePassword: profile.mustChangePassword,
      );
      if (profile.mustChangePassword) {
        status = SessionStatus.passwordChangeRequired;
      }
    } on ApiException catch (e) {
      if (e.status == 401) {
        await _storage.clear();
        session = null;
        status = SessionStatus.unauthenticated;
      }
    } catch (_) {
      // Sin red: arranca con la sesión guardada.
    }
  }

  Future<void> establish(Session session) async {
    this.session = session;
    status = session.mustChangePassword
        ? SessionStatus.passwordChangeRequired
        : SessionStatus.authenticated;
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

  /// El servidor exige cambiar la contraseña (403): bloquea el resto de la app.
  void requirePasswordChange() {
    final current = session;
    if (current == null || status == SessionStatus.passwordChangeRequired) {
      return;
    }
    if (status != SessionStatus.authenticated) return;
    session = current.copyWith(mustChangePassword: true);
    status = SessionStatus.passwordChangeRequired;
    notifyListeners();
  }

  /// Refleja un perfil editado (nombre/apellido) en la sesión activa.
  void updateUser(AuthUser user) {
    final current = session;
    if (current == null) return;
    session = current.copyWith(user: user);
    notifyListeners();
  }

  /// La contraseña ya se cambió: se conserva el mismo token.
  void completePasswordChange() {
    final current = session;
    if (current == null) return;
    session = current.copyWith(mustChangePassword: false);
    status = SessionStatus.authenticated;
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
    if (status != SessionStatus.authenticated &&
        status != SessionStatus.passwordChangeRequired) {
      return;
    }
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
    _passwordChangeSub?.cancel();
    super.dispose();
  }
}
