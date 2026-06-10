import 'package:travel_matrix/features/account/domain/entities/agent_profile.dart';

abstract class AccountRepository {
  Future<AgentProfile> getAgentProfile();
}
