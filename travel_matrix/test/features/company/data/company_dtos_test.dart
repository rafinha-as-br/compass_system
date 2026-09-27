import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/company/data/dtos/agent_summary_dto.dart';
import 'package:travel_matrix/features/company/data/dtos/company_dto.dart';
import 'package:travel_matrix/features/company/data/dtos/invite_agent_response_dto.dart';
import 'package:travel_matrix/features/company/domain/entities/agent_role.dart';
import 'package:travel_matrix/features/company/domain/entities/plan_type.dart';

void main() {
  group('CompanyDto', () {
    test('maps GET /api/companies/me data including the current agent role', () {
      final company = CompanyDto.fromJson({
        'id': '7',
        'name': 'Aurora Viagens',
        'cnpj': '12.345.678/0001-90',
        'domain': 'aurora.com.br',
        'plan': 'PRO',
        'currentAgent': {'id': '3', 'role': 'OWNER'},
      }).toDomain();

      expect(company.id, '7');
      expect(company.name, 'Aurora Viagens');
      expect(company.domain, 'aurora.com.br');
      expect(company.plan, PlanType.pro);
      expect(company.currentAgentId, '3');
      expect(company.currentAgentRole, AgentRole.owner);
      expect(company.isCurrentAgentOwner, isTrue);
    });

    test('unknown plan falls back to FREE and missing currentAgent to MEMBER', () {
      final company = CompanyDto.fromJson({'name': 'X', 'plan': 'GOLD'}).toDomain();

      expect(company.plan, PlanType.free);
      expect(company.currentAgentRole, AgentRole.member);
      expect(company.isCurrentAgentOwner, isFalse);
    });
  });

  group('AgentSummaryDto', () {
    test('parses memberSince as an instant and role case-insensitively', () {
      final agent = AgentSummaryDto.fromJson({
        'id': '9',
        'name': 'Bruno Member',
        'login': 'bruno.member@aurora.com.br',
        'role': 'member',
        'memberSince': '2026-09-18T22:00:00Z',
      }).toDomain();

      expect(agent.role, AgentRole.member);
      expect(agent.memberSince, DateTime.utc(2026, 9, 18, 22));
    });

    test('memberSince null (agent older than the module) stays null', () {
      final agent = AgentSummaryDto.fromJson({
        'id': '1',
        'name': 'Legado',
        'login': 'legado@aurora.com.br',
        'role': 'OWNER',
        'memberSince': null,
      }).toDomain();

      expect(agent.memberSince, isNull);
      expect(agent.role, AgentRole.owner);
    });

    test('roleToApi produces the backend enum names', () {
      expect(AgentSummaryDto.roleToApi(AgentRole.owner), 'OWNER');
      expect(AgentSummaryDto.roleToApi(AgentRole.member), 'MEMBER');
    });
  });

  test('InviteAgentResponseDto keeps the one-time temporary password', () {
    final invited = InviteAgentResponseDto.fromJson({
      'id': '12',
      'name': 'Ana Paula Ribeiro',
      'login': 'ana.paula.ribeiro@aurora.com.br',
      'role': 'MEMBER',
      'memberSince': '2026-09-18T22:00:00Z',
      'temporaryPassword': 'Xy7kQ2pL9m',
    }).toDomain();

    expect(invited.agent.login, 'ana.paula.ribeiro@aurora.com.br');
    expect(invited.agent.role, AgentRole.member);
    expect(invited.temporaryPassword, 'Xy7kQ2pL9m');
  });
}
