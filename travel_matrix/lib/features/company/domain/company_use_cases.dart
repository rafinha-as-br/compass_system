import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/company/domain/company_repository.dart';
import 'package:travel_matrix/features/company/domain/entities/agent_role.dart';
import 'package:travel_matrix/features/company/domain/entities/company.dart';
import 'package:travel_matrix/features/company/domain/entities/company_agent.dart';
import 'package:travel_matrix/features/company/domain/entities/invited_agent.dart';

/// Use cases do módulo company (mesmo formato de `UserUseCases`).
class CompanyUseCases {
  final CompanyRepository _repository;

  const CompanyUseCases(this._repository);

  Future<Result<Company>> getMyCompany() => _repository.getMyCompany();

  Future<Result<List<CompanyAgent>>> getAgents() => _repository.getAgents();

  Future<Result<InvitedAgent>> inviteAgent(String name) =>
      _repository.inviteAgent(name);

  Future<Result> removeAgent(String agentId) => _repository.removeAgent(agentId);

  Future<Result<CompanyAgent>> changeRole(String agentId, AgentRole role) =>
      _repository.changeRole(agentId, role);
}
