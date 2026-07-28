import 'package:travel_matrix/features/account/domain/entities/agent_profile.dart';

abstract class AccountRepository {
  Future<AgentProfile> getAgentProfile();

  Future<AgentProfile> updateAgentProfile(AgentProfile profile);

  /// Verifica a senha atual do agente logado, lançando se estiver incorreta.
  Future<void> verifyPassword(String email, String password);
}
