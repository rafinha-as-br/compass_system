import 'package:travel_matrix/features/company/domain/entities/company_agent.dart';

/// Resultado do convite: o agente criado e a senha temporária, que o backend
/// devolve uma única vez (MVP sem e-mail).
class InvitedAgent {
  final CompanyAgent agent;
  final String temporaryPassword;

  const InvitedAgent({required this.agent, required this.temporaryPassword});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvitedAgent &&
          runtimeType == other.runtimeType &&
          agent == other.agent &&
          temporaryPassword == other.temporaryPassword;

  @override
  int get hashCode => Object.hash(agent, temporaryPassword);
}
