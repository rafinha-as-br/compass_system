import 'package:travel_matrix/core/validators/cpf_cnpj_validator.dart';
import 'package:travel_matrix/features/account/domain/account_repository.dart';
import 'package:travel_matrix/features/account/domain/entities/agent_profile.dart';

class UpdateAgentProfile {
  final AccountRepository _repository;

  const UpdateAgentProfile(this._repository);

  Future<AgentProfile> call({
    required AgentProfile current,
    required AgentProfile updated,
    String? currentPassword,
  }) async {
    if (updated.cpf.isNotEmpty && !CpfCnpjValidator.isValidCpf(updated.cpf)) {
      throw StateError('Invalid CPF.');
    }
    if (updated.cnpj.isNotEmpty && !CpfCnpjValidator.isValidCnpj(updated.cnpj)) {
      throw StateError('Invalid CNPJ.');
    }

    final documentsChanged = updated.cpf != current.cpf || updated.cnpj != current.cnpj;

    // CPF/CNPJ são dados de auditoria usados para rastrear responsabilidade
    // sobre itinerários e pacotes, então exigem reautenticação por senha.
    if (documentsChanged) {
      if (currentPassword == null || currentPassword.isEmpty) {
        throw StateError('Current password confirmation is required to change CPF/CNPJ.');
      }
      await _repository.verifyPassword(current.email, currentPassword);
    }

    return _repository.updateAgentProfile(updated);
  }
}
