import 'package:travel_matrix/features/account/domain/account_repository.dart';
import 'package:travel_matrix/features/account/domain/entities/agent_profile.dart';

class GetAgentProfile {
  final AccountRepository _repository;

  const GetAgentProfile(this._repository);

  Future<AgentProfile> call() {
    return _repository.getAgentProfile();
  }
}
