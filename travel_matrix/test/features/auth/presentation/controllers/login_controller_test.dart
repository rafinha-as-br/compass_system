import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/auth/domain/auth_repository.dart';
import 'package:travel_matrix/features/auth/domain/entities/auth_session.dart';
import 'package:travel_matrix/features/auth/domain/login.dart';
import 'package:travel_matrix/features/auth/presentation/controllers/login_controller.dart';

/// Fake escrito à mão pelo mesmo motivo do login_test.dart: interface de
/// método único, sem necessidade de mocktail/mockito.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.sessionToReturn, this.errorToThrow});

  final AuthSession? sessionToReturn;
  final Object? errorToThrow;

  @override
  Future<AuthSession> login(String email, String password) async {
    if (errorToThrow != null) throw errorToThrow!;
    return sessionToReturn!;
  }
}

void main() {
  group('LoginController', () {
    test(
      'login bem-sucedido retorna Result.success com o token e limpa isLoading',
      () async {
        final repository = _FakeAuthRepository(
          sessionToReturn: const AuthSession(token: 'abc123', userType: 'AGENTE'),
        );
        final controller = LoginController(login: Login(repository));

        final result = await controller.login('agente@compass.com', 'senha123');

        expect(result.isSuccess, isTrue);
        expect(result.data, 'abc123');
        expect(controller.state.isLoading, isFalse);
        expect(controller.state.errorMessage, isNull);
      },
    );

    test(
      'login com usuário não-agente retorna Result.failure e preenche errorMessage',
      () async {
        final repository = _FakeAuthRepository(
          sessionToReturn: const AuthSession(token: 'abc123', userType: 'CLIENTE'),
        );
        final controller = LoginController(login: Login(repository));

        final result = await controller.login('cliente@compass.com', 'senha123');

        expect(result.isSuccess, isFalse);
        expect(controller.state.errorMessage, isNotNull);
        expect(controller.state.isLoading, isFalse);
      },
    );

    test(
      'login com falha do repositório retorna Result.failure com a mensagem do erro',
      () async {
        final repository = _FakeAuthRepository(
          errorToThrow: StateError('Invalid credentials. Please try again.'),
        );
        final controller = LoginController(login: Login(repository));

        final result = await controller.login('agente@compass.com', 'senha-errada');

        expect(result.isSuccess, isFalse);
        expect(result.error, 'Invalid credentials. Please try again.');
      },
    );

    test('login com erro que não é StateError usa mensagem genérica', () async {
      final repository = _FakeAuthRepository(errorToThrow: Exception('boom'));
      final controller = LoginController(login: Login(repository));

      final result = await controller.login('agente@compass.com', 'senha123');

      expect(result.isSuccess, isFalse);
      expect(result.error, 'An error occurred during login.');
    });

    test('notifica os listeners no início e no fim do login (2 notificações)', () async {
      final repository = _FakeAuthRepository(
        sessionToReturn: const AuthSession(token: 'abc123', userType: 'AGENTE'),
      );
      final controller = LoginController(login: Login(repository));

      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.login('agente@compass.com', 'senha123');

      expect(notifications, 2);
    });

    test('showLogin alterna o estado showLogin e notifica uma vez', () {
      final controller = LoginController(login: Login(_FakeAuthRepository()));

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.showLogin();

      expect(controller.state.showLogin, isTrue);
      expect(notifications, 1);
    });
  });
}
