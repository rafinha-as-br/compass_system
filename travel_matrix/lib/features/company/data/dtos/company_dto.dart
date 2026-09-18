import 'package:travel_matrix/features/company/data/dtos/agent_summary_dto.dart';
import 'package:travel_matrix/features/company/domain/entities/company.dart';
import 'package:travel_matrix/features/company/domain/entities/plan_type.dart';

/// `data` de `GET /api/companies/me`.
class CompanyDto {
  final String id;
  final String name;
  final String cnpj;
  final String domain;
  final String plan;
  final String currentAgentId;
  final String currentAgentRole;

  const CompanyDto({
    required this.id,
    required this.name,
    required this.cnpj,
    required this.domain,
    required this.plan,
    required this.currentAgentId,
    required this.currentAgentRole,
  });

  factory CompanyDto.fromJson(Map<String, dynamic> json) {
    final currentAgent = json['currentAgent'] as Map<String, dynamic>? ?? const {};
    return CompanyDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      cnpj: json['cnpj']?.toString() ?? '',
      domain: json['domain']?.toString() ?? '',
      plan: json['plan']?.toString() ?? '',
      currentAgentId: currentAgent['id']?.toString() ?? '',
      currentAgentRole: currentAgent['role']?.toString() ?? '',
    );
  }

  Company toDomain() {
    return Company(
      id: id,
      name: name,
      cnpj: cnpj,
      domain: domain,
      plan: planFromApi(plan),
      currentAgentId: currentAgentId,
      currentAgentRole: AgentSummaryDto.roleFromApi(currentAgentRole),
    );
  }

  /// Plano desconhecido cai em FREE — é só exibição, não vale quebrar a tela.
  static PlanType planFromApi(String raw) {
    switch (raw.toUpperCase()) {
      case 'PRO':
        return PlanType.pro;
      case 'BASIC':
        return PlanType.basic;
      default:
        return PlanType.free;
    }
  }
}
