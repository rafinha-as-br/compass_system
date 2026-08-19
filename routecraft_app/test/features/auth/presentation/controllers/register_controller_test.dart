import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/auth/domain/entities/client_registration.dart';
import 'package:routecraft_app/features/auth/domain/repositories/client_registration_repository.dart';
import 'package:routecraft_app/features/auth/domain/usecases/register_client_usecase.dart';
import 'package:routecraft_app/features/auth/presentation/controllers/register_controller.dart';

const _registration = ClientRegistration(
  name: 'John Doe',
  cpf: '12345678900',
  age: 30,
  gender: 'M',
  phone: '11999999999',
  email: 'john@example.com',
  password: 'secret',
);

class _StubClientRegistrationRepository implements ClientRegistrationRepository {
  final Result<String> result;
  const _StubClientRegistrationRepository(this.result);

  @override
  Future<Result<String>> register(ClientRegistration registration) async => result;
}

void main() {
  group('RegisterController.register', () {
    test('on success, clears loading/error and marks isSuccess', () async {
      final useCase = RegisterClientUseCase(
        const _StubClientRegistrationRepository(Result.success('ok')),
      );
      final controller = RegisterController(registerUseCase: useCase);

      final success = await controller.register(_registration);

      expect(success, isTrue);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.isSuccess, isTrue);
      expect(controller.state.errorMessage, isNull);
    });

    test('on duplicate e-mail failure, exposes the server error message', () async {
      final useCase = RegisterClientUseCase(
        const _StubClientRegistrationRepository(
          Result.failure('Este e-mail já está cadastrado.'),
        ),
      );
      final controller = RegisterController(registerUseCase: useCase);

      final success = await controller.register(_registration);

      expect(success, isFalse);
      expect(controller.state.isSuccess, isFalse);
      expect(controller.state.errorMessage, 'Este e-mail já está cadastrado.');
    });
  });
}
