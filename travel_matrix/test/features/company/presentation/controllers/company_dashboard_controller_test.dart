import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/company/domain/company_use_cases.dart';
import 'package:travel_matrix/features/company/domain/entities/agent_role.dart';
import 'package:travel_matrix/features/company/domain/entities/company.dart';
import 'package:travel_matrix/features/company/domain/entities/company_agent.dart';
import 'package:travel_matrix/features/company/domain/entities/plan_type.dart';
import 'package:travel_matrix/features/company/presentation/controllers/company_dashboard_controller.dart';

class _MockCompanyUseCases extends Mock implements CompanyUseCases {}

const _company = Company(
  id: '7',
  name: 'Aurora Viagens',
  cnpj: '12.345.678/0001-90',
  domain: 'aurora.com.br',
  plan: PlanType.pro,
  currentAgentId: '1',
  currentAgentRole: AgentRole.owner,
);

const _owner = CompanyAgent(
  id: '1',
  name: 'Carla Owner',
  login: 'carla.owner@aurora.com.br',
  role: AgentRole.owner,
);

const _member = CompanyAgent(
  id: '2',
  name: 'Bruno Member',
  login: 'bruno.member@aurora.com.br',
  role: AgentRole.member,
);

void main() {
  late _MockCompanyUseCases useCases;

  setUp(() {
    useCases = _MockCompanyUseCases();
    when(() => useCases.getMyCompany()).thenAnswer((_) async => const Result.success(_company));
    when(() => useCases.getAgents())
        .thenAnswer((_) async => const Result.success([_owner, _member]));
  });

  Future<CompanyDashboardController> loaded() async {
    final controller = CompanyDashboardController(useCases: useCases);
    await pumpEventQueue();
    return controller;
  }

  test('loads company and agents, marking the current agent and owner flag', () async {
    final controller = await loaded();
    final state = controller.state;

    expect(state.isLoading, isFalse);
    expect(state.hasLoadError, isFalse);
    expect(state.company?.name, 'Aurora Viagens');
    expect(state.isOwner, isTrue);
    expect(state.agents.length, 2);
    expect(state.agents.first.isCurrentAgent, isTrue);
    expect(state.agents.last.isCurrentAgent, isFalse);
  });

  test('sole OWNER rule: the only owner cannot be removed or demoted', () async {
    final controller = await loaded();
    final state = controller.state;

    expect(state.ownerCount, 1);
    expect(state.isSoleOwner(state.agents.first), isTrue);
    expect(state.isSoleOwner(state.agents.last), isFalse);
  });

  test('two owners: neither is the sole owner', () async {
    when(() => useCases.getAgents()).thenAnswer(
      (_) async => Result.success([_owner, _member.copyWith(role: AgentRole.owner)]),
    );
    final controller = await loaded();

    expect(controller.state.ownerCount, 2);
    expect(controller.state.isSoleOwner(controller.state.agents.first), isFalse);
  });

  test('company failure is a load error, without leaking the raw message', () async {
    when(() => useCases.getMyCompany())
        .thenAnswer((_) async => const Result.failure('ApiException(404): sem empresa'));
    final controller = await loaded();

    expect(controller.state.hasLoadError, isTrue);
    expect(controller.state.company, isNull);
    expect(controller.state.errorMessage, isNull);
  });

  test('agents failure is also a load error (list needs the role)', () async {
    when(() => useCases.getAgents()).thenAnswer((_) async => const Result.failure('boom'));
    final controller = await loaded();

    expect(controller.state.hasLoadError, isTrue);
  });

  test('removeAgent success refreshes the list and reports true', () async {
    final controller = await loaded();
    when(() => useCases.removeAgent('2')).thenAnswer((_) async => const Result.success());
    when(() => useCases.getAgents()).thenAnswer((_) async => const Result.success([_owner]));

    final ok = await controller.removeAgent('2');

    expect(ok, isTrue);
    expect(controller.state.agents.length, 1);
    expect(controller.state.isMutating, isFalse);
    verify(() => useCases.removeAgent('2')).called(1);
  });

  test('removeAgent failure exposes the backend business message once', () async {
    final controller = await loaded();
    when(() => useCases.removeAgent('1')).thenAnswer(
      (_) async => const Result.failure('Você é o único OWNER da empresa — promova outro agente antes.'),
    );

    final ok = await controller.removeAgent('1');

    expect(ok, isFalse);
    expect(controller.state.isMutating, isFalse);
    expect(controller.takeErrorMessage(), contains('único OWNER'));
    expect(controller.takeErrorMessage(), isNull);
    expect(controller.state.agents.length, 2);
  });

  test('changeRole success refreshes with the new role', () async {
    final controller = await loaded();
    final promoted = _member.copyWith(role: AgentRole.owner);
    when(() => useCases.changeRole('2', AgentRole.owner))
        .thenAnswer((_) async => Result.success(promoted));
    when(() => useCases.getAgents())
        .thenAnswer((_) async => Result.success([_owner, promoted]));

    final ok = await controller.changeRole('2', AgentRole.owner);

    expect(ok, isTrue);
    expect(controller.state.ownerCount, 2);
  });

  test('starts loading before the use cases resolve', () {
    when(() => useCases.getMyCompany()).thenAnswer(
      (_) => Future.delayed(const Duration(milliseconds: 10), () => const Result.success(_company)),
    );
    final controller = CompanyDashboardController(useCases: useCases);

    expect(controller.state.isLoading, isTrue);
  });
}
