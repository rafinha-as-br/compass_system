import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/company/domain/entities/agent_role.dart';
import 'package:travel_matrix/features/company/domain/entities/company.dart';
import 'package:travel_matrix/features/company/domain/entities/company_agent.dart';
import 'package:travel_matrix/features/company/domain/entities/invited_agent.dart';

/// Operações do módulo company, sempre no contexto da empresa do agente
/// autenticado.
abstract class CompanyRepository {
  Future<Result<Company>> getMyCompany();
  Future<Result<List<CompanyAgent>>> getAgents();
  Future<Result<InvitedAgent>> inviteAgent(String name);
  Future<Result> removeAgent(String agentId);
  Future<Result<CompanyAgent>> changeRole(String agentId, AgentRole role);
}
