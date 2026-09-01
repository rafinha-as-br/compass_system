import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/users/domain/entities/travel_summary.dart';
import 'package:travel_matrix/features/users/domain/entities/user.dart';
import 'package:travel_matrix/features/users/domain/entities/user_stats.dart';
import 'package:travel_matrix/features/users/domain/entities/user_status.dart';
import 'package:travel_matrix/features/users/domain/user_client_repository.dart';
import 'package:travel_matrix/features/users/domain/user_crud_use_cases.dart';

class _MockUserClientRepository extends Mock implements UserClientRepository {}

UserClient _buildUser() {
  return UserClient(
    backEndId: '1',
    domainId: '1',
    name: 'Agent Smith',
    cpf: '000.000.000-00',
    sex: 'M',
    phoneNumber: '11999999999',
    status: UserClientStatus(status: ActiveStatus(), lastLogin: null),
    email: 'agent@example.com',
    travels: const <TravelSummary>[],
    stats: UserStats(totalTravels: 0, uniqueDestinationsCount: 0),
  );
}

void main() {
  late _MockUserClientRepository repository;
  late UserUseCases useCases;

  setUp(() {
    repository = _MockUserClientRepository();
    useCases = UserUseCases(repository);
  });

  test('getAuthenticatedUser delegates to repository.getAuthenticatedUser', () async {
    final user = _buildUser();
    when(() => repository.getAuthenticatedUser()).thenAnswer((_) async => Result.success(user));

    final result = await useCases.getAuthenticatedUser();

    expect(result.isSuccess, isTrue);
    expect(result.data!.name, 'Agent Smith');
    verify(() => repository.getAuthenticatedUser()).called(1);
  });

  test('getAuthenticatedUser propagates failure from the repository', () async {
    when(() => repository.getAuthenticatedUser())
        .thenAnswer((_) async => const Result.failure('Not authenticated.'));

    final result = await useCases.getAuthenticatedUser();

    expect(result.isSuccess, isFalse);
    expect(result.error, 'Not authenticated.');
  });
}
