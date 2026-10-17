class AuthSession {
  final String token;
  final String userType;

  /// Agente convidado com senha temporária: precisa trocá-la antes de qualquer
  /// outra tela.
  final bool mustChangePassword;

  const AuthSession({
    required this.token,
    required this.userType,
    this.mustChangePassword = false,
  });
}
