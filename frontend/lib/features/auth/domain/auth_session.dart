/// Plain DTO mirroring the backend `LoginResponse`.
class AuthenticatedUser {
  const AuthenticatedUser({
    required this.id,
    required this.email,
    required this.name,
  });

  final String id;
  final String email;
  final String name;

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }
}

/// Bundle of what a successful `/api/auth/login` yields.
class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final AuthenticatedUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String,
      user: AuthenticatedUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
