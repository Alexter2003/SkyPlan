import '../../domain/entities/session.dart';
import 'auth_user_model.dart';

class SessionModel extends Session {
  const SessionModel({
    required super.token,
    required super.expiresAt,
    required super.mustChangePassword,
    required super.user,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      mustChangePassword: json['mustChangePassword'] as bool,
      user: AuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
