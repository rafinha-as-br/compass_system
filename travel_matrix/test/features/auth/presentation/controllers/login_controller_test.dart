import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/auth/domain/auth_repository.dart';
import 'package:travel_matrix/features/auth/domain/entities/auth_session.dart';
import 'package:travel_matrix/features/auth/presentation/controllers/login_controller.dart';

/// Fake escrito à mão pelo mesmo motivo do login_test.dart: interface
/// pequena, sem necessidade de mocktail/mockito.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.sessionToReturn,
    this.errorToThrow,
    this.requestPasswordResetError,
    this.resetPasswordError,
  });

  final AuthSession? sessionToReturn;
  final Object? errorToThrow;
  final Object? requestPasswordResetError;
  final Object? resetPasswordError;

  String? lastRequestPasswordResetEmail;
  String? lastResetPasswordToken;
  String? lastResetPasswordNewPassword;

  @override
  Future<AuthSession> login(String email, String password) async {
    if (errorToThrow != null) throw errorToThrow!;
    return sessionToReturn!;
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    lastRequestPasswordResetEmail = email;
    if (requestPasswordResetError != null) throw requestPasswordResetError!;
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    lastResetPasswordToken = token;
    lastResetPasswordNewPassword = newPassword;
    if (resetPasswordError != null) throw resetPasswordError!;
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
        final controller = LoginController(repository: repository);

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
        final controller = LoginController(repository: repository);

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
        final controller = LoginController(repository: repository);

        final result = await controller.login('agente@compass.com', 'senha-errada');

        expect(result.isSuccess, isFalse);
        expect(result.error, 'Invalid credentials. Please try again.');
      },
    );

    test('login com erro que não é StateError usa mensagem genérica', () async {
      final repository = _FakeAuthRepository(errorToThrow: Exception('boom'));
      final controller = LoginController(repository: repository);

      final result = await controller.login('agente@compass.com', 'senha123');

      expect(result.isSuccess, isFalse);
      expect(result.error, 'An error occurred during login.');
    });

    test('notifica os listeners no início e no fim do login (2 notificações)', () async {
      final repository = _FakeAuthRepository(
        sessionToReturn: const AuthSession(token: 'abc123', userType: 'AGENTE'),
      );
      final controller = LoginController(repository: repository);

      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.login('agente@compass.com', 'senha123');

      expect(notifications, 2);
    });

    test('showLogin alterna o painel entre login e welcome, e notifica uma vez', () {
      final controller = LoginController(repository: _FakeAuthRepository());

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.showLogin();

      expect(controller.state.panel, AuthPanel.welcome);
      expect(notifications, 1);

      controller.showLogin();

      expect(controller.state.panel, AuthPanel.login);
      expect(notifications, 2);
    });

    test('showForgotPassword e showResetPassword navegam para os painéis correspondentes', () {
      final controller = LoginController(repository: _FakeAuthRepository());

      controller.showForgotPassword();
      expect(controller.state.panel, AuthPanel.forgotPassword);

      controller.showResetPassword();
      expect(controller.state.panel, AuthPanel.resetPassword);

      controller.showLoginPanel();
      expect(controller.state.panel, AuthPanel.login);
    });

    test(
      'requestPasswordReset bem-sucedido retorna Result.success e limpa isLoading',
      () async {
        final repository = _FakeAuthRepository();
        final controller = LoginController(repository: repository);

        final result = await controller.requestPasswordReset('agente@compass.com');

        expect(result.isSuccess, isTrue);
        expect(repository.lastRequestPasswordResetEmail, 'agente@compass.com');
        expect(controller.state.isLoading, isFalse);
        expect(controller.state.errorMessage, isNull);
      },
    );

    test(
      'requestPasswordReset com falha do repositório retorna Result.failure com a mensagem do erro',
      () async {
        final repository = _FakeAuthRepository(
          requestPasswordResetError: StateError('An error occurred. Please try again.'),
        );
        final controller = LoginController(repository: repository);

        final result = await controller.requestPasswordReset('agente@compass.com');

        expect(result.isSuccess, isFalse);
        expect(result.error, 'An error occurred. Please try again.');
        expect(controller.state.errorMessage, 'An error occurred. Please try again.');
      },
    );

    test(
      'resetPassword bem-sucedido retorna Result.success e limpa isLoading',
      () async {
        final repository = _FakeAuthRepository();
        final controller = LoginController(repository: repository);

        final result = await controller.resetPassword('token-123', 'novaSenha456');

        expect(result.isSuccess, isTrue);
        expect(repository.lastResetPasswordToken, 'token-123');
        expect(repository.lastResetPasswordNewPassword, 'novaSenha456');
        expect(controller.state.isLoading, isFalse);
        expect(controller.state.errorMessage, isNull);
      },
    );

    test(
      'resetPassword com token inválido retorna Result.failure com a mensagem do erro',
      () async {
        final repository = _FakeAuthRepository(
          resetPasswordError: StateError('Token inválido ou expirado.'),
        );
        final controller = LoginController(repository: repository);

        final result = await controller.resetPassword('token-invalido', 'novaSenha456');

        expect(result.isSuccess, isFalse);
        expect(result.error, 'Token inválido ou expirado.');
        expect(controller.state.errorMessage, 'Token inválido ou expirado.');
      },
    );
  });
}
