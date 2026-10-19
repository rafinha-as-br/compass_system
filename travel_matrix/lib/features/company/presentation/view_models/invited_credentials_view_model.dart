import 'package:travel_matrix/features/company/domain/entities/invited_agent.dart';

/// Credenciais exibidas uma única vez na confirmação pós-convite.
class InvitedCredentialsViewModel {
  final String agentName;
  final String login;
  final String temporaryPassword;

  const InvitedCredentialsViewModel({
    required this.agentName,
    required this.login,
    required this.temporaryPassword,
  });

  factory InvitedCredentialsViewModel.fromDomain(InvitedAgent invited) {
    return InvitedCredentialsViewModel(
      agentName: invited.agent.name,
      login: invited.agent.login,
      temporaryPassword: invited.temporaryPassword,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvitedCredentialsViewModel &&
          runtimeType == other.runtimeType &&
          agentName == other.agentName &&
          login == other.login &&
          temporaryPassword == other.temporaryPassword;

  @override
  int get hashCode => Object.hash(agentName, login, temporaryPassword);
}
