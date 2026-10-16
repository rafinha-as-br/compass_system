import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/core/services/compass_service/api_exception.dart';
import 'package:travel_matrix/features/company/data/company_data_source.dart';
import 'package:travel_matrix/features/company/data/dtos/agent_summary_dto.dart';
import 'package:travel_matrix/features/company/data/dtos/company_dto.dart';
import 'package:travel_matrix/features/company/data/dtos/invite_agent_response_dto.dart';
import 'package:travel_matrix/features/company/domain/company_repository.dart';
import 'package:travel_matrix/features/company/domain/entities/agent_role.dart';
import 'package:travel_matrix/features/company/domain/entities/company.dart';
import 'package:travel_matrix/features/company/domain/entities/company_agent.dart';
import 'package:travel_matrix/features/company/domain/entities/invited_agent.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyDataSource _dataSource;

  const CompanyRepositoryImpl(this._dataSource);

  @override
  Future<Result<Company>> getMyCompany() {
    return _guard(() async {
      final response = await _dataSource.getMyCompany();
      return CompanyDto.fromJson(_data(response)).toDomain();
    });
  }

  @override
  Future<Result<List<CompanyAgent>>> getAgents() {
    return _guard(() async {
      final response = await _dataSource.getAgents();
      final data = response['data'] as List<dynamic>? ?? const [];
      return data
          .map((e) => AgentSummaryDto.fromJson(e as Map<String, dynamic>).toDomain())
          .toList();
    });
  }

  @override
  Future<Result<InvitedAgent>> inviteAgent(String name) {
    return _guard(() async {
      final response = await _dataSource.inviteAgent(name);
      return InviteAgentResponseDto.fromJson(_data(response)).toDomain();
    });
  }

  @override
  Future<Result> removeAgent(String agentId) {
    return _guard(() async {
      await _dataSource.removeAgent(agentId);
      return null;
    });
  }

  @override
  Future<Result<CompanyAgent>> changeRole(String agentId, AgentRole role) {
    return _guard(() async {
      final response =
          await _dataSource.changeRole(agentId, AgentSummaryDto.roleToApi(role));
      return AgentSummaryDto.fromJson(_data(response)).toDomain();
    });
  }

  Map<String, dynamic> _data(Map<String, dynamic> response) {
    return response['data'] as Map<String, dynamic>? ?? const {};
  }

  /// Converte exceções em [Result.failure]. Erros da API viram a mensagem de
  /// negócio do backend (ex.: "Você é o único OWNER…"), que a tela pode exibir.
  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
