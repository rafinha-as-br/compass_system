import 'package:travel_matrix/features/account/domain/entities/agent_profile.dart';

abstract class AccountRepository {
  Future<AgentProfile> getAgentProfile();

  /// Throws [StateError] with the backend message when the change is refused
  /// (e.g. wrong current password).
  Future<void> changePassword(String currentPassword, String newPassword);
}
