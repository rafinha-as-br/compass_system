import 'package:travel_matrix/features/company/domain/entities/company.dart';
import 'package:travel_matrix/features/company/domain/entities/plan_type.dart';

/// Dados da empresa para o card de cabeçalho do Painel + papel do agente
/// logado (decide se as ações de gestão aparecem).
class CompanyHeaderViewModel {
  final String id;
  final String name;
  final String cnpj;
  final String domain;
  final PlanType plan;
  final String currentAgentId;
  final bool isOwner;

  const CompanyHeaderViewModel({
    required this.id,
    required this.name,
    required this.cnpj,
    required this.domain,
    required this.plan,
    required this.currentAgentId,
    required this.isOwner,
  });

  factory CompanyHeaderViewModel.fromDomain(Company company) {
    return CompanyHeaderViewModel(
      id: company.id,
      name: company.name,
      cnpj: company.cnpj,
      domain: company.domain,
      plan: company.plan,
      currentAgentId: company.currentAgentId,
      isOwner: company.isCurrentAgentOwner,
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Rótulo do plano como o backend nomeia (FREE/BASIC/PRO).
  String get planLabel => plan.name.toUpperCase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyHeaderViewModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          cnpj == other.cnpj &&
          domain == other.domain &&
          plan == other.plan &&
          currentAgentId == other.currentAgentId &&
          isOwner == other.isOwner;

  @override
  int get hashCode =>
      Object.hash(id, name, cnpj, domain, plan, currentAgentId, isOwner);
}
