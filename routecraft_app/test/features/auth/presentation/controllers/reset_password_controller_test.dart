import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:routecraft_app/features/auth/domain/entities/auth_session.dart';
import 'package:routecraft_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:routecraft_app/features/auth/presentation/controllers/reset_password_controller.dart';

class _StubAuthRepository implements AuthRepository {
  Result<void> result;
  _StubAuthRepository(this.result);

  @override
  Future<Result<AuthSession>> login(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> requestPasswordReset(String email) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> resetPassword(String token, String newPassword) async => result;
}

void main() {
  group('ResetPasswordController.resetPassword', () {
    test('on success, clears loading/error state and returns true', () async {
      final useCase = ResetPasswordUseCase(_StubAuthRepository(const Result.success(null)));
      final controller = ResetPasswordController(resetPasswordUseCase: useCase);

      final success = await controller.resetPassword('token-123', 'novaSenha456');

      expect(success, isTrue);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.errorMessage, isNull);
    });

    test('on failure, exposes the error message and returns false', () async {
      final useCase = ResetPasswordUseCase(
        _StubAuthRepository(const Result.failure('Token inválido ou expirado.')),
      );
      final controller = ResetPasswordController(resetPasswordUseCase: useCase);

      final success = await controller.resetPassword('token-invalido', 'novaSenha456');

      expect(success, isFalse);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.errorMessage, 'Token inválido ou expirado.');
    });
  });
}
