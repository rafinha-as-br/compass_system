import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/core/services/compass_service/api_exception.dart';
import 'package:travel_matrix/features/account/domain/account_repository.dart';
import 'package:travel_matrix/features/account/domain/entities/agent_profile.dart';
import 'package:travel_matrix/features/account/domain/get_agent_profile.dart';
import 'package:travel_matrix/features/account/domain/update_agent_profile.dart';
import 'package:travel_matrix/features/account/presentation/controllers/account_controller.dart';

class _FakeAccountRepository implements AccountRepository {
  _FakeAccountRepository({this.profile, this.verifyPasswordError, this.updateAgentProfileError});

  AgentProfile? profile;
  final Object? verifyPasswordError;
  final Object? updateAgentProfileError;

  @override
  Future<AgentProfile> getAgentProfile() async => profile!;

  @override
  Future<AgentProfile> updateAgentProfile(AgentProfile profile) async {
    if (updateAgentProfileError != null) throw updateAgentProfileError!;
    this.profile = profile;
    return profile;
  }

  @override
  Future<void> verifyPassword(String email, String password) async {
    if (verifyPasswordError != null) throw verifyPasswordError!;
  }
}

const _profile = AgentProfile(
  id: '1',
  name: 'Agente Smith',
  email: 'smith@matrix.com',
  cpf: '111.444.777-35',
  cnpj: '',
  phoneNumber: '11999999999',
);

void main() {
  group('AccountController.updateProfile', () {
    late _FakeAccountRepository repository;
    late AccountController controller;

    Future<void> ready() async {
      // load() é chamado no construtor; espera o microtask concluir.
      await Future<void>.delayed(Duration.zero);
    }

    setUp(() async {
      repository = _FakeAccountRepository(profile: _profile);
      controller = AccountController(
        getAgentProfile: GetAgentProfile(repository),
        updateAgentProfile: UpdateAgentProfile(repository),
      );
      await ready();
    });

    test('atualiza nome/telefone com sucesso e reflete no estado', () async {
      final result = await controller.updateProfile(
        name: 'Novo Nome',
        email: _profile.email,
        phoneNumber: '11888888888',
        cpf: _profile.cpf,
        cnpj: _profile.cnpj,
      );

      expect(result.isSuccess, isTrue);
      expect(controller.state.profile?.name, 'Novo Nome');
      expect(controller.state.profile?.phoneNumber, '11888888888');
    });

    test('retorna falha quando CPF muda sem senha atual', () async {
      final result = await controller.updateProfile(
        name: _profile.name,
        email: _profile.email,
        phoneNumber: _profile.phoneNumber,
        cpf: '222.333.444-05',
        cnpj: _profile.cnpj,
      );

      expect(result.isSuccess, isFalse);
      expect(controller.state.profile?.cpf, _profile.cpf);
    });

    test('retorna falha quando a senha atual está incorreta', () async {
      repository = _FakeAccountRepository(
        profile: _profile,
        verifyPasswordError: StateError('Incorrect current password.'),
      );
      controller = AccountController(
        getAgentProfile: GetAgentProfile(repository),
        updateAgentProfile: UpdateAgentProfile(repository),
      );
      await ready();

      final result = await controller.updateProfile(
        name: _profile.name,
        email: _profile.email,
        phoneNumber: _profile.phoneNumber,
        cpf: '222.333.444-05',
        cnpj: _profile.cnpj,
        currentPassword: 'senha-errada',
      );

      expect(result.isSuccess, isFalse);
      expect(result.error, 'Incorrect current password.');
    });

    test('propaga a mensagem da API quando o backend rejeita a atualização', () async {
      repository = _FakeAccountRepository(
        profile: _profile,
        updateAgentProfileError: ApiException('Not found', 404),
      );
      controller = AccountController(
        getAgentProfile: GetAgentProfile(repository),
        updateAgentProfile: UpdateAgentProfile(repository),
      );
      await ready();

      final result = await controller.updateProfile(
        name: _profile.name,
        email: _profile.email,
        phoneNumber: _profile.phoneNumber,
        cpf: _profile.cpf,
        cnpj: _profile.cnpj,
      );

      expect(result.isSuccess, isFalse);
      expect(result.error, 'Not found');
    });
  });
}
