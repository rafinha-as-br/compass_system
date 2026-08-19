import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/auth/domain/entities/client_registration.dart';
import 'package:routecraft_app/features/auth/domain/repositories/client_registration_repository.dart';
import 'package:routecraft_app/features/auth/domain/usecases/register_client_usecase.dart';

const _registration = ClientRegistration(
  name: 'John Doe',
  cpf: '12345678900',
  age: 30,
  gender: 'M',
  phone: '11999999999',
  email: 'john@example.com',
  password: 'secret',
);

class _FakeClientRegistrationRepository implements ClientRegistrationRepository {
  Result<String>? nextResult;
  ClientRegistration? captured;

  @override
  Future<Result<String>> register(ClientRegistration registration) async {
    captured = registration;
    return nextResult!;
  }
}

void main() {
  group('RegisterClientUseCase', () {
    test('delegates to the repository with the given registration data', () async {
      final repository = _FakeClientRegistrationRepository()
        ..nextResult = const Result.success('Cliente cadastrado com sucesso.');
      final useCase = RegisterClientUseCase(repository);

      final result = await useCase(_registration);

      expect(repository.captured, _registration);
      expect(result.isSuccess, isTrue);
    });

    test('propagates a failure result from the repository', () async {
      final repository = _FakeClientRegistrationRepository()
        ..nextResult = const Result.failure('Este e-mail já está cadastrado.');
      final useCase = RegisterClientUseCase(repository);

      final result = await useCase(_registration);

      expect(result.isSuccess, isFalse);
      expect(
        (result as Failure<String>).message,
        'Este e-mail já está cadastrado.',
      );
    });
  });
}
