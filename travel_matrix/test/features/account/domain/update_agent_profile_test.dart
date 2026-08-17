import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/account/domain/account_repository.dart';
import 'package:travel_matrix/features/account/domain/entities/agent_profile.dart';
import 'package:travel_matrix/features/account/domain/update_agent_profile.dart';

/// Fake escrito à mão, seguindo o mesmo padrão usado nos testes de auth:
/// interface pequena, sem necessidade de mocktail/mockito.
class _FakeAccountRepository implements AccountRepository {
  _FakeAccountRepository({this.verifyPasswordError});

  final Object? verifyPasswordError;

  String? lastVerifiedEmail;
  String? lastVerifiedPassword;
  AgentProfile? lastUpdatedProfile;

  @override
  Future<AgentProfile> getAgentProfile() {
    throw UnimplementedError();
  }

  @override
  Future<AgentProfile> updateAgentProfile(AgentProfile profile) async {
    lastUpdatedProfile = profile;
    return profile;
  }

  @override
  Future<void> verifyPassword(String email, String password) async {
    lastVerifiedEmail = email;
    lastVerifiedPassword = password;
    if (verifyPasswordError != null) throw verifyPasswordError!;
  }
}

const _baseProfile = AgentProfile(
  id: '1',
  name: 'Agente Smith',
  email: 'smith@matrix.com',
  cpf: '111.444.777-35',
  cnpj: '',
  phoneNumber: '11999999999',
);

void main() {
  group('UpdateAgentProfile', () {
    test('atualiza sem exigir senha quando CPF/CNPJ não mudam', () async {
      final repository = _FakeAccountRepository();
      final updateAgentProfile = UpdateAgentProfile(repository);

      final updated = _baseProfile.copyWithName('Novo Nome');
      final result = await updateAgentProfile(
        current: _baseProfile,
        updated: updated,
      );

      expect(result.name, 'Novo Nome');
      expect(repository.lastVerifiedEmail, isNull);
    });

    test('exige senha atual quando CPF muda', () async {
      final repository = _FakeAccountRepository();
      final updateAgentProfile = UpdateAgentProfile(repository);

      final updated = _baseProfile.copyWithCpf('222.333.444-05');

      expect(
        () => updateAgentProfile(current: _baseProfile, updated: updated),
        throwsA(isA<StateError>()),
      );
    });

    test('verifica a senha atual via repositório quando CPF muda', () async {
      final repository = _FakeAccountRepository();
      final updateAgentProfile = UpdateAgentProfile(repository);

      final updated = _baseProfile.copyWithCpf('222.333.444-05');
      await updateAgentProfile(
        current: _baseProfile,
        updated: updated,
        currentPassword: 'senha123',
      );

      expect(repository.lastVerifiedEmail, _baseProfile.email);
      expect(repository.lastVerifiedPassword, 'senha123');
      expect(repository.lastUpdatedProfile?.cpf, '222.333.444-05');
    });

    test('propaga a falha de senha incorreta sem persistir a alteração', () async {
      final repository = _FakeAccountRepository(
        verifyPasswordError: StateError('Incorrect current password.'),
      );
      final updateAgentProfile = UpdateAgentProfile(repository);

      final updated = _baseProfile.copyWithCpf('222.333.444-05');

      expect(
        () => updateAgentProfile(
          current: _baseProfile,
          updated: updated,
          currentPassword: 'senha-errada',
        ),
        throwsA(isA<StateError>()),
      );
      expect(repository.lastUpdatedProfile, isNull);
    });

    test('rejeita CPF com formato inválido', () async {
      final repository = _FakeAccountRepository();
      final updateAgentProfile = UpdateAgentProfile(repository);

      final updated = _baseProfile.copyWithCpf('123');

      expect(
        () => updateAgentProfile(
          current: _baseProfile,
          updated: updated,
          currentPassword: 'senha123',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rejeita CNPJ com formato inválido', () async {
      final repository = _FakeAccountRepository();
      final updateAgentProfile = UpdateAgentProfile(repository);

      final updated = _baseProfile.copyWithCnpj('123');

      expect(
        () => updateAgentProfile(
          current: _baseProfile,
          updated: updated,
          currentPassword: 'senha123',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}

extension _AgentProfileCopy on AgentProfile {
  AgentProfile copyWithName(String name) => AgentProfile(
        id: id,
        name: name,
        email: email,
        cpf: cpf,
        cnpj: cnpj,
        phoneNumber: phoneNumber,
      );

  AgentProfile copyWithCpf(String cpf) => AgentProfile(
        id: id,
        name: name,
        email: email,
        cpf: cpf,
        cnpj: cnpj,
        phoneNumber: phoneNumber,
      );

  AgentProfile copyWithCnpj(String cnpj) => AgentProfile(
        id: id,
        name: name,
        email: email,
        cpf: cpf,
        cnpj: cnpj,
        phoneNumber: phoneNumber,
      );
}
