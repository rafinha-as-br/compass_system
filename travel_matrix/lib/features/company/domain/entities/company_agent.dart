import 'package:travel_matrix/features/company/domain/entities/agent_role.dart';

/// Agente listado no Painel da Empresa. [memberSince] é nulo para agentes
/// anteriores ao módulo company (o backend não tem a data deles).
class CompanyAgent {
  final String id;
  final String name;
  final String login;
  final AgentRole role;
  final DateTime? memberSince;

  const CompanyAgent({
    required this.id,
    required this.name,
    required this.login,
    required this.role,
    this.memberSince,
  });

  CompanyAgent copyWith({AgentRole? role}) {
    return CompanyAgent(
      id: id,
      name: name,
      login: login,
      role: role ?? this.role,
      memberSince: memberSince,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyAgent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          login == other.login &&
          role == other.role &&
          memberSince == other.memberSince;

  @override
  int get hashCode => Object.hash(id, name, login, role, memberSince);
}
