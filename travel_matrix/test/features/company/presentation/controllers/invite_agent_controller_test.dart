import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/company/domain/company_use_cases.dart';
import 'package:travel_matrix/features/company/domain/entities/agent_role.dart';
import 'package:travel_matrix/features/company/domain/entities/company_agent.dart';
import 'package:travel_matrix/features/company/domain/entities/invited_agent.dart';
import 'package:travel_matrix/features/company/presentation/controllers/invite_agent_controller.dart';

class _MockCompanyUseCases extends Mock implements CompanyUseCases {}

const _invited = InvitedAgent(
  agent: CompanyAgent(
    id: '12',
    name: 'Ana Paula Ribeiro',
    login: 'ana.paula.ribeiro2@aurora.com.br',
    role: AgentRole.member,
  ),
  temporaryPassword: 'Xy7kQ2pL9m',
);

void main() {
  late _MockCompanyUseCases useCases;
  late InviteAgentController controller;

  setUp(() {
    useCases = _MockCompanyUseCases();
    controller = InviteAgentController(domain: 'aurora.com.br', useCases: useCases);
  });

  test('setName updates the login preview on every keystroke', () {
    controller.setName('Ana');
    expect(controller.state.loginPreview, 'ana@aurora.com.br');

    controller.setName('Ana Paula Ribeiro');
    expect(controller.state.loginPreview, 'ana.paula.ribeiro@aurora.com.br');

    controller.setName('   ');
    expect(controller.state.loginPreview, '');
    expect(controller.state.canSubmit, isFalse);
  });

  test('submit with a blank name does nothing', () async {
    final ok = await controller.submit();

    expect(ok, isFalse);
    verifyNever(() => useCases.inviteAgent(any()));
  });

  test('submit success stores the one-time credentials (backend may add a suffix)', () async {
    when(() => useCases.inviteAgent('Ana Paula Ribeiro'))
        .thenAnswer((_) async => const Result.success(_invited));
    controller.setName('  Ana Paula Ribeiro ');

    final ok = await controller.submit();

    expect(ok, isTrue);
    expect(controller.state.isSubmitting, isFalse);
    expect(controller.state.createdCredentials?.login, 'ana.paula.ribeiro2@aurora.com.br');
    expect(controller.state.createdCredentials?.temporaryPassword, 'Xy7kQ2pL9m');
    expect(controller.state.errorMessage, isNull);
  });

  test('submit failure keeps the form and exposes the backend message', () async {
    when(() => useCases.inviteAgent('Ana'))
        .thenAnswer((_) async => const Result.failure('Apenas agentes OWNER podem gerenciar os agentes da empresa.'));
    controller.setName('Ana');

    final ok = await controller.submit();

    expect(ok, isFalse);
    expect(controller.state.createdCredentials, isNull);
    expect(controller.state.errorMessage, contains('OWNER'));
    expect(controller.state.canSubmit, isTrue);
  });
}
