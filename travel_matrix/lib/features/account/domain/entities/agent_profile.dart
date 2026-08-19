class AgentProfile {
  final String id;
  final String name;
  final String email;
  final String cpf;
  final String cnpj;
  final String phoneNumber;

  const AgentProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.cpf,
    required this.cnpj,
    required this.phoneNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          cpf == other.cpf &&
          cnpj == other.cnpj &&
          phoneNumber == other.phoneNumber;

  @override
  int get hashCode => Object.hash(id, name, email, cpf, cnpj, phoneNumber);
}
