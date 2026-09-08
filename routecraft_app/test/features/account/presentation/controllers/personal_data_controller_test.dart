import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/account/domain/entities/client_profile.dart';
import 'package:routecraft_app/features/account/domain/repositories/client_profile_repository.dart';
import 'package:routecraft_app/features/account/domain/usecases/client_profile_usecases.dart';
import 'package:routecraft_app/features/account/presentation/controllers/personal_data_controller.dart';

class _FakeClientProfileRepository implements ClientProfileRepository {
  Result<ClientProfile>? nextGetResult;
  Result<ClientProfile>? nextUpdateResult;
  Result<void>? nextResetPasswordResult;
  ClientProfile? lastUpdateRequest;

  @override
  Future<Result<ClientProfile>> getCurrentUser() async => nextGetResult!;

  @override
  Future<Result<ClientProfile>> updateUser(ClientProfile profile) async {
    lastUpdateRequest = profile;
    return nextUpdateResult!;
  }

  @override
  Future<Result<void>> resetPassword(String id) async => nextResetPasswordResult!;
}

const _profile = ClientProfile(
  id: '1',
  name: 'Maria Cliente',
  cpf: '12345678900',
  phoneNumber: '11999998888',
  email: 'maria@email.com',
  age: 30,
  sex: 'F',
);

void main() {
  group('PersonalDataController', () {
    test('loads the profile on construction', () async {
      final repository = _FakeClientProfileRepository()..nextGetResult = const Result.success(_profile);
      final controller = PersonalDataController(useCases: ClientProfileUseCases(repository));

      expect(controller.state.isLoading, isTrue);
      await Future.microtask(() {});

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.profile?.name, 'Maria Cliente');
    });

    test('surfaces a Failure message when the profile fails to load', () async {
      final repository = _FakeClientProfileRepository()
        ..nextGetResult = const Result.failure('Não autorizado');
      final controller = PersonalDataController(useCases: ClientProfileUseCases(repository));

      await Future.microtask(() {});

      expect(controller.state.profile, isNull);
      expect(controller.state.errorMessage, 'Não autorizado');
    });

    test('save() sends the four editable fields and updates state on success', () async {
      final repository = _FakeClientProfileRepository()..nextGetResult = const Result.success(_profile);
      final controller = PersonalDataController(useCases: ClientProfileUseCases(repository));
      await Future.microtask(() {});

      repository.nextUpdateResult = const Result.success(
        ClientProfile(
          id: '1',
          name: 'Maria Souza',
          cpf: '12345678900',
          phoneNumber: '11888887777',
          email: 'maria@email.com',
          age: 31,
          sex: 'M',
        ),
      );

      final success = await controller.save(name: 'Maria Souza', phoneNumber: '11888887777', age: 31, sex: 'M');

      expect(success, isTrue);
      expect(controller.state.profile?.name, 'Maria Souza');
      expect(controller.state.profile?.age, 31);
      expect(repository.lastUpdateRequest?.cpf, '12345678900', reason: 'read-only fields must be preserved');
      expect(repository.lastUpdateRequest?.email, 'maria@email.com', reason: 'read-only fields must be preserved');
    });

    test('save() keeps the previous profile and surfaces the error on failure', () async {
      final repository = _FakeClientProfileRepository()..nextGetResult = const Result.success(_profile);
      final controller = PersonalDataController(useCases: ClientProfileUseCases(repository));
      await Future.microtask(() {});

      repository.nextUpdateResult = const Result.failure('Dados inválidos');

      final success = await controller.save(name: 'Maria Souza', phoneNumber: '11888887777', age: 31, sex: 'M');

      expect(success, isFalse);
      expect(controller.state.profile?.name, 'Maria Cliente');
      expect(controller.state.errorMessage, 'Dados inválidos');
    });

    test('resetPassword() returns true on success', () async {
      final repository = _FakeClientProfileRepository()..nextGetResult = const Result.success(_profile);
      final controller = PersonalDataController(useCases: ClientProfileUseCases(repository));
      await Future.microtask(() {});

      repository.nextResetPasswordResult = const Result.success(null);

      final success = await controller.resetPassword();

      expect(success, isTrue);
      expect(controller.state.isResettingPassword, isFalse);
    });

    test('resetPassword() surfaces the error message on failure', () async {
      final repository = _FakeClientProfileRepository()..nextGetResult = const Result.success(_profile);
      final controller = PersonalDataController(useCases: ClientProfileUseCases(repository));
      await Future.microtask(() {});

      repository.nextResetPasswordResult = const Result.failure('Usuário não encontrado');

      final success = await controller.resetPassword();

      expect(success, isFalse);
      expect(controller.state.errorMessage, 'Usuário não encontrado');
    });
  });
}
