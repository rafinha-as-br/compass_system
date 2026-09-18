import 'package:intl/intl.dart';
import 'package:travel_matrix/features/company/domain/entities/agent_role.dart';
import 'package:travel_matrix/features/company/domain/entities/company_agent.dart';

/// Linha da tabela de agentes e dados do Diálogo do Agente.
class AgentRowViewModel {
  final String id;
  final String name;
  final String login;
  final AgentRole role;
  final DateTime? memberSince;

  /// Verdadeiro para o próprio agente logado (sufixo "(você)" na tabela).
  final bool isCurrentAgent;

  const AgentRowViewModel({
    required this.id,
    required this.name,
    required this.login,
    required this.role,
    required this.isCurrentAgent,
    this.memberSince,
  });

  factory AgentRowViewModel.fromDomain(
    CompanyAgent agent, {
    required String currentAgentId,
  }) {
    return AgentRowViewModel(
      id: agent.id,
      name: agent.name,
      login: agent.login,
      role: agent.role,
      memberSince: agent.memberSince,
      isCurrentAgent: agent.id == currentAgentId,
    );
  }

  bool get isOwner => role == AgentRole.owner;

  /// Rótulo do papel como o backend nomeia (OWNER/MEMBER).
  String get roleLabel => role.name.toUpperCase();

  /// `dd/MM/yyyy`, ou nulo quando o backend não tem a data (agente anterior
  /// ao módulo company) — a tela omite a linha em vez de mostrar placeholder.
  String? get memberSinceLabel {
    final date = memberSince;
    return date == null ? null : DateFormat('dd/MM/yyyy').format(date.toLocal());
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
      other is AgentRowViewModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          login == other.login &&
          role == other.role &&
          memberSince == other.memberSince &&
          isCurrentAgent == other.isCurrentAgent;

  @override
  int get hashCode =>
      Object.hash(id, name, login, role, memberSince, isCurrentAgent);
}
