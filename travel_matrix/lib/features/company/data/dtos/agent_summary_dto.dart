import 'package:travel_matrix/features/company/domain/entities/agent_role.dart';
import 'package:travel_matrix/features/company/domain/entities/company_agent.dart';

/// Item de `GET /api/companies/me/agents` (e `data` de `PUT .../role`).
class AgentSummaryDto {
  final String id;
  final String name;
  final String login;
  final String role;
  final String? memberSince;

  const AgentSummaryDto({
    required this.id,
    required this.name,
    required this.login,
    required this.role,
    this.memberSince,
  });

  factory AgentSummaryDto.fromJson(Map<String, dynamic> json) {
    return AgentSummaryDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      login: json['login']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      memberSince: json['memberSince']?.toString(),
    );
  }

  CompanyAgent toDomain() {
    return CompanyAgent(
      id: id,
      name: name,
      login: login,
      role: roleFromApi(role),
      memberSince: memberSince == null ? null : DateTime.tryParse(memberSince!),
    );
  }

  static AgentRole roleFromApi(String raw) {
    return raw.toUpperCase() == 'OWNER' ? AgentRole.owner : AgentRole.member;
  }

  static String roleToApi(AgentRole role) {
    return role == AgentRole.owner ? 'OWNER' : 'MEMBER';
  }
}
