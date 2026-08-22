import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:routecraft_app/features/auth/domain/entities/auth_session.dart';
import 'package:routecraft_app/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:routecraft_app/features/auth/presentation/controllers/forgot_password_controller.dart';

class _StubAuthRepository implements AuthRepository {
  Result<void> result;
  _StubAuthRepository(this.result);

  @override
  Future<Result<AuthSession>> login(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> requestPasswordReset(String email) async => result;

  @override
  Future<Result<void>> resetPassword(String token, String newPassword) async {
    throw UnimplementedError();
  }
}

void main() {
  group('ForgotPasswordController.requestPasswordReset', () {
    test('on success, clears loading/error state and returns true', () async {
      final useCase = RequestPasswordResetUseCase(
        _StubAuthRepository(const Result.success(null)),
      );
      final controller = ForgotPasswordController(requestPasswordResetUseCase: useCase);

      final success = await controller.requestPasswordReset('a@b.com');

      expect(success, isTrue);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.errorMessage, isNull);
    });

    test('on failure, exposes the error message and returns false', () async {
      final useCase = RequestPasswordResetUseCase(
        _StubAuthRepository(const Result.failure('Não foi possível completar a solicitação.')),
      );
      final controller = ForgotPasswordController(requestPasswordResetUseCase: useCase);

      final success = await controller.requestPasswordReset('a@b.com');

      expect(success, isFalse);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.errorMessage, 'Não foi possível completar a solicitação.');
    });
  });
}
