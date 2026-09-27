import 'package:travel_matrix/features/company/data/dtos/agent_summary_dto.dart';
import 'package:travel_matrix/features/company/domain/entities/invited_agent.dart';

/// `data` de `POST /api/companies/me/agents/invite`: o agente criado mais a
/// senha temporária (só nesta resposta).
class InviteAgentResponseDto {
  final AgentSummaryDto agent;
  final String temporaryPassword;

  const InviteAgentResponseDto({
    required this.agent,
    required this.temporaryPassword,
  });

  factory InviteAgentResponseDto.fromJson(Map<String, dynamic> json) {
    return InviteAgentResponseDto(
      agent: AgentSummaryDto.fromJson(json),
      temporaryPassword: json['temporaryPassword']?.toString() ?? '',
    );
  }

  InvitedAgent toDomain() {
    return InvitedAgent(
      agent: agent.toDomain(),
      temporaryPassword: temporaryPassword,
    );
  }
}
