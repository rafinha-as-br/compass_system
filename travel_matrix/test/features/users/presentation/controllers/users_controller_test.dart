import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/features/users/domain/entities/new_user.dart';
import 'package:travel_matrix/features/users/domain/entities/travel_summary.dart';
import 'package:travel_matrix/features/users/domain/entities/user.dart';
import 'package:travel_matrix/features/users/domain/entities/user_stats.dart';
import 'package:travel_matrix/features/users/domain/entities/user_status.dart';
import 'package:travel_matrix/features/users/domain/user_crud_use_cases.dart';
import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';

class _MockUserUseCases extends Mock implements UserUseCases {}

UserClient _buildUser(String id) {
  return UserClient(
    backEndId: id,
    domainId: id,
    name: 'User $id',
    cpf: '000.000.000-00',
    sex: 'M',
    phoneNumber: '11999999999',
    status: UserClientStatus(status: ActiveStatus(), lastLogin: null),
    email: 'user$id@example.com',
    travels: const <TravelSummary>[],
    stats: UserStats(totalTravels: 0, uniqueDestinationsCount: 0),
  );
}

NewUser _buildNewUser() {
  return NewUser(
    name: 'fallback',
    cpf: '000.000.000-00',
    sex: 'M',
    phoneNumber: '11999999999',
    email: 'fallback@example.com',
    password: 'fallback',
  );
}

void main() {
  late _MockUserUseCases useCases;

  setUpAll(() {
    registerFallbackValue(_buildUser('fallback'));
    registerFallbackValue(_buildNewUser());
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'auth_token': 'test-token'});
    await AuthStorageService.init();
    useCases = _MockUserUseCases();
  });

  test('fetchUsers populates the list on success', () async {
    when(() => useCases.getAllUsers())
        .thenAnswer((_) async => Result.success([_buildUser('1')]));

    final controller = UsersController(useCases: useCases);
    await pumpEventQueue();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.users, hasLength(1));
    expect(controller.state.errorMessage, isNull);
  });

  test(
    'fetchUsers keeps the previously loaded users when a refetch fails',
    () async {
      when(() => useCases.getAllUsers())
          .thenAnswer((_) async => Result.success([_buildUser('1')]));

      final controller = UsersController(useCases: useCases);
      await pumpEventQueue();
      expect(controller.state.users, hasLength(1));

      when(() => useCases.getAllUsers())
          .thenAnswer((_) async => const Result.failure('Network error'));
      await controller.fetchUsers();

      expect(controller.state.users, hasLength(1));
      expect(controller.state.errorMessage, 'Network error');
    },
  );

  test(
    'fetchUsers keeps the previously loaded users when an unexpected exception is thrown',
    () async {
      when(() => useCases.getAllUsers())
          .thenAnswer((_) async => Result.success([_buildUser('1')]));

      final controller = UsersController(useCases: useCases);
      await pumpEventQueue();
      expect(controller.state.users, hasLength(1));

      when(() => useCases.getAllUsers()).thenThrow(StateError('boom'));
      await controller.fetchUsers();

      expect(controller.state.users, hasLength(1));
      expect(controller.state.errorMessage, contains('boom'));
    },
  );

  test('deactivateUser surfaces a friendly message instead of swallowing the exception', () async {
    when(() => useCases.getAllUsers())
        .thenAnswer((_) async => Result.success([_buildUser('1')]));

    final controller = UsersController(useCases: useCases);
    await pumpEventQueue();

    when(() => useCases.deactivateUser(any(), any()))
        .thenThrow(StateError('offline'));

    final success = await controller.deactivateUser('1', 'Client request');

    expect(success, isFalse);
    expect(controller.state.errorMessage, contains('offline'));
  });

  test('resetPassword surfaces the failure reason instead of only returning false', () async {
    when(() => useCases.getAllUsers())
        .thenAnswer((_) async => Result.success([_buildUser('1')]));

    final controller = UsersController(useCases: useCases);
    await pumpEventQueue();

    when(() => useCases.resetPassword(any()))
        .thenAnswer((_) async => const Result.failure('User has no email on file'));

    final success = await controller.resetPassword('1');

    expect(success, isFalse);
    expect(controller.state.errorMessage, 'User has no email on file');
  });

  test('forceLogout surfaces a friendly message instead of swallowing the exception', () async {
    when(() => useCases.getAllUsers())
        .thenAnswer((_) async => Result.success([_buildUser('1')]));

    final controller = UsersController(useCases: useCases);
    await pumpEventQueue();

    when(() => useCases.forceLogout(any())).thenThrow(StateError('timeout'));

    final success = await controller.forceLogout('1');

    expect(success, isFalse);
    expect(controller.state.errorMessage, contains('timeout'));
  });

  group('createUser', () {
    test('builds a NewUser from the raw form map and delegates to the use case', () async {
      when(() => useCases.getAllUsers()).thenAnswer((_) async => Result.success(const []));
      final controller = UsersController(useCases: useCases);
      await pumpEventQueue();

      when(() => useCases.createUser(any())).thenAnswer((_) async => const Result.success());

      final success = await controller.createUser({
        'name': 'New Client',
        'cpf': '111.111.111-11',
        'email': 'new@client.com',
        'phoneNumber': '11988887777',
        'password': 'secret123',
        'sex': 'F',
        'birthDate': '2000-05-10T00:00:00.000',
      });

      expect(success, isTrue);
      final captured = verify(() => useCases.createUser(captureAny())).captured.single as NewUser;
      expect(captured.name, 'New Client');
      expect(captured.email, 'new@client.com');
      expect(captured.password, 'secret123');
      expect(captured.birthDate, DateTime.parse('2000-05-10T00:00:00.000'));
      verify(() => useCases.getAllUsers()).called(2); // once on construction, once on refetch
    });

    test('surfaces the failure reason instead of only returning false', () async {
      when(() => useCases.getAllUsers()).thenAnswer((_) async => Result.success(const []));
      final controller = UsersController(useCases: useCases);
      await pumpEventQueue();

      when(() => useCases.createUser(any()))
          .thenAnswer((_) async => const Result.failure('E-mail already in use'));

      final success = await controller.createUser({'name': 'New Client'});

      expect(success, isFalse);
      expect(controller.state.errorMessage, 'E-mail already in use');
    });
  });

  group('updateUser', () {
    test('carries over status/travels/stats from the currently loaded user', () async {
      when(() => useCases.getAllUsers())
          .thenAnswer((_) async => Result.success([_buildUser('1')]));
      final controller = UsersController(useCases: useCases);
      await pumpEventQueue();

      when(() => useCases.updateUser(any())).thenAnswer((_) async => const Result.success());

      final success = await controller.updateUser({
        'id': '1',
        'name': 'Updated Name',
        'cpf': '000.000.000-00',
        'email': 'updated@example.com',
        'phoneNumber': '11999999999',
        'sex': 'M',
      });

      expect(success, isTrue);
      final captured = verify(() => useCases.updateUser(captureAny())).captured.single as UserClient;
      expect(captured.name, 'Updated Name');
      expect(captured.email, 'updated@example.com');
      expect(captured.backEndId, '1');
      expect(captured.status.status, isA<ActiveStatus>()); // carried over, not touched by the form
    });

    test('surfaces the failure reason instead of only returning false', () async {
      when(() => useCases.getAllUsers())
          .thenAnswer((_) async => Result.success([_buildUser('1')]));
      final controller = UsersController(useCases: useCases);
      await pumpEventQueue();

      when(() => useCases.updateUser(any()))
          .thenAnswer((_) async => const Result.failure('CPF already registered'));

      final success = await controller.updateUser({'id': '1', 'name': 'X'});

      expect(success, isFalse);
      expect(controller.state.errorMessage, 'CPF already registered');
    });
  });
}
