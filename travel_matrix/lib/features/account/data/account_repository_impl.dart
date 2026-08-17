import 'package:travel_matrix/features/account/data/account_data_source.dart';
import 'package:travel_matrix/features/account/data/dtos/agent_profile_dto.dart';
import 'package:travel_matrix/features/account/domain/account_repository.dart';
import 'package:travel_matrix/features/account/domain/entities/agent_profile.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountDataSource _dataSource;

  const AccountRepositoryImpl(this._dataSource);

  @override
  Future<AgentProfile> getAgentProfile() async {
    final response = await _dataSource.getAgentProfile();
    if (response['status'] != 'success') {
      throw StateError(response['message'] as String? ?? 'Failed to load profile.');
    }

    final data = response['data'] as Map<String, dynamic>;
    return AgentProfileDto.fromJson(data).toDomain();
  }

  @override
  Future<AgentProfile> updateAgentProfile(AgentProfile profile) async {
    final payload = AgentProfileDto.fromDomain(profile).toJson();
    final response = await _dataSource.updateAgentProfile(payload);
    if (response['status'] != 'success') {
      throw StateError(response['message'] as String? ?? 'Failed to update profile.');
    }

    final data = response['data'] as Map<String, dynamic>;
    return AgentProfileDto.fromJson(data).toDomain();
  }

  @override
  Future<void> verifyPassword(String email, String password) async {
    final response = await _dataSource.verifyPassword(email, password);
    if (response['status'] != 'success') {
      throw StateError('Incorrect current password.');
    }
  }
}
