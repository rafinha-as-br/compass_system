import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/auth/domain/entities/auth_session.dart';
import 'package:routecraft_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:routecraft_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:routecraft_app/features/auth/presentation/controllers/login_controller.dart';

class _StubAuthRepository implements AuthRepository {
  Result<AuthSession> result;
  _StubAuthRepository(this.result);

  @override
  Future<Result<AuthSession>> login(String email, String password) async {
    return result;
  }
}

void main() {
  group('LoginController.login', () {
    test('on success, saves the token and clears loading/error state', () async {
      const session = AuthSession(token: 'jwt', userType: 'CLIENTE', email: 'a@b.com');
      final useCase = LoginUseCase(_StubAuthRepository(const Result.success(session)));
      String? savedToken;

      final controller = LoginController(
        loginUseCase: useCase,
        saveToken: (token) async => savedToken = token,
      );

      final success = await controller.login('a@b.com', 'secret');

      expect(success, isTrue);
      expect(savedToken, 'jwt');
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.errorMessage, isNull);
    });

    test('on failure, exposes the error message and does not save a token', () async {
      final useCase = LoginUseCase(
        _StubAuthRepository(const Result.failure('E-mail ou senha incorretos.')),
      );
      var saveTokenCalled = false;

      final controller = LoginController(
        loginUseCase: useCase,
        saveToken: (token) async => saveTokenCalled = true,
      );

      final success = await controller.login('a@b.com', 'wrong');

      expect(success, isFalse);
      expect(saveTokenCalled, isFalse);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.errorMessage, 'E-mail ou senha incorretos.');
    });

    test('a new attempt clears the previous error message', () async {
      final repository = _StubAuthRepository(
        const Result.failure('E-mail ou senha incorretos.'),
      );
      final controller = LoginController(
        loginUseCase: LoginUseCase(repository),
        saveToken: (token) async {},
      );

      await controller.login('a@b.com', 'wrong');
      expect(controller.state.errorMessage, isNotNull);

      repository.result = const Result.success(
        AuthSession(token: 'jwt', userType: 'CLIENTE', email: 'a@b.com'),
      );

      await controller.login('a@b.com', 'secret');
      expect(controller.state.errorMessage, isNull);
    });
  });
}
