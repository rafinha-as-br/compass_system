import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/features/account/domain/account_repository.dart';
import 'package:travel_matrix/features/account/domain/entities/agent_profile.dart';
import 'package:travel_matrix/features/account/domain/get_agent_profile.dart';

class _MockAccountRepository extends Mock implements AccountRepository {}

void main() {
  late _MockAccountRepository repository;
  late GetAgentProfile useCase;

  setUp(() {
    repository = _MockAccountRepository();
    useCase = GetAgentProfile(repository);
  });

  const profile = AgentProfile(
    id: '1',
    name: 'Agent Smith',
    email: 'agent@matrix.com',
    cpf: '000.000.000-00',
    cnpj: '00.000.000/0000-00',
    phoneNumber: '11999999999',
  );

  test('returns the profile from the repository on success', () async {
    when(() => repository.getAgentProfile()).thenAnswer((_) async => profile);

    final result = await useCase();

    expect(result, profile);
    verify(() => repository.getAgentProfile()).called(1);
  });

  test('propagates the failure when the repository throws', () async {
    when(() => repository.getAgentProfile())
        .thenThrow(StateError('Not authenticated.'));

    expect(() => useCase(), throwsA(isA<StateError>()));
  });
}
