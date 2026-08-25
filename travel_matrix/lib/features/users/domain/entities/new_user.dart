/// Data needed to create a new client user — deliberately separate from
/// [UserClient], which represents an existing user and has no business
/// carrying a plaintext [password] or a creation-only [birthDate].
class NewUser {
  final String name;
  final String cpf;
  final String sex;
  final String phoneNumber;
  final String email;
  final String password;
  final DateTime? birthDate;

  NewUser({
    required this.name,
    required this.cpf,
    required this.sex,
    required this.phoneNumber,
    required this.email,
    required this.password,
    this.birthDate,
  });
}
