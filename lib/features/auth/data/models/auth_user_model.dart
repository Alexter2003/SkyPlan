import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    required super.username,
    required super.emailConfirmed,
    required super.createdAt,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      emailConfirmed: json['emailConfirmed'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
