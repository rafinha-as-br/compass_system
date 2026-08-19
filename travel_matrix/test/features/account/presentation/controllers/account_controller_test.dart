import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/features/account/domain/entities/agent_profile.dart';
import 'package:travel_matrix/features/account/domain/get_agent_profile.dart';
import 'package:travel_matrix/features/account/presentation/controllers/account_controller.dart';

class _MockGetAgentProfile extends Mock implements GetAgentProfile {}

void main() {
  late _MockGetAgentProfile getAgentProfile;

  setUp(() {
    getAgentProfile = _MockGetAgentProfile();
  });

  const profile = AgentProfile(
    id: '1',
    name: 'Agent Smith',
    email: 'agent@matrix.com',
    cpf: '000.000.000-00',
    cnpj: '00.000.000/0000-00',
    phoneNumber: '11999999999',
  );

  test('loads the profile and exposes it through state on success', () async {
    when(() => getAgentProfile()).thenAnswer((_) async => profile);

    final controller = AccountController(getAgentProfile: getAgentProfile);
    await pumpEventQueue();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.hasError, isFalse);
    expect(controller.state.profile?.id, profile.id);
  });

  test('exposes a hasError state without leaking the raw exception on failure', () async {
    when(() => getAgentProfile()).thenThrow(StateError('Not authenticated.'));

    final controller = AccountController(getAgentProfile: getAgentProfile);
    await pumpEventQueue();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.hasError, isTrue);
    expect(controller.state.profile, isNull);
  });

  test('starts in a loading state before the use case resolves', () {
    when(() => getAgentProfile()).thenAnswer(
      (_) => Future.delayed(const Duration(milliseconds: 10), () => profile),
    );

    final controller = AccountController(getAgentProfile: getAgentProfile);

    expect(controller.state.isLoading, isTrue);
  });
}
