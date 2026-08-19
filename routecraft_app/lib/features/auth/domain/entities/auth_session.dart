class AuthSession {
  final String token;
  final String userType;
  final String email;

  const AuthSession({
    required this.token,
    required this.userType,
    required this.email,
  });
}
