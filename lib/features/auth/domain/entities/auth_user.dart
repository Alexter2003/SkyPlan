/// Datos de cuenta devueltos por la API.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.username,
    required this.emailConfirmed,
    required this.createdAt,
    this.firstName,
    this.lastName,
  });

  final int id;
  final String email;
  final String username;
  final bool emailConfirmed;
  final DateTime createdAt;

  /// `null` mientras el usuario no los haya definido.
  final String? firstName;
  final String? lastName;

  AuthUser copyWith({String? firstName, String? lastName}) => AuthUser(
    id: id,
    email: email,
    username: username,
    emailConfirmed: emailConfirmed,
    createdAt: createdAt,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
  );
}
