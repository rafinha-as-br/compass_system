import 'package:travel_matrix/features/company/domain/entities/agent_role.dart';
import 'package:travel_matrix/features/company/domain/entities/plan_type.dart';

/// Empresa (tenant) do agente autenticado, com o papel dele nela.
class Company {
  final String id;
  final String name;
  final String cnpj;
  final String domain;
  final PlanType plan;
  final String currentAgentId;
  final AgentRole currentAgentRole;

  const Company({
    required this.id,
    required this.name,
    required this.cnpj,
    required this.domain,
    required this.plan,
    required this.currentAgentId,
    required this.currentAgentRole,
  });

  bool get isCurrentAgentOwner => currentAgentRole == AgentRole.owner;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Company &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          cnpj == other.cnpj &&
          domain == other.domain &&
          plan == other.plan &&
          currentAgentId == other.currentAgentId &&
          currentAgentRole == other.currentAgentRole;

  @override
  int get hashCode =>
      Object.hash(id, name, cnpj, domain, plan, currentAgentId, currentAgentRole);
}
