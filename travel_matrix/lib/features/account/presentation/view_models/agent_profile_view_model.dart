import 'package:travel_matrix/features/account/domain/entities/agent_profile.dart';

class AgentProfileViewModel {
  final String id;
  final String name;
  final String email;
  final String cpf;
  final String cnpj;
  final String phoneNumber;

  const AgentProfileViewModel({
    required this.id,
    required this.name,
    required this.email,
    required this.cpf,
    required this.cnpj,
    required this.phoneNumber,
  });

  factory AgentProfileViewModel.fromDomain(AgentProfile profile) {
    return AgentProfileViewModel(
      id: profile.id,
      name: profile.name,
      email: profile.email,
      cpf: profile.cpf,
      cnpj: profile.cnpj,
      phoneNumber: profile.phoneNumber,
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentProfileViewModel &&
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
