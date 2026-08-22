import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/auth/domain/entities/auth_session.dart';
import 'package:routecraft_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:routecraft_app/features/auth/domain/usecases/reset_password_usecase.dart';

class _FakeAuthRepository implements AuthRepository {
  Result<void>? nextResult;
  String? capturedToken;
  String? capturedNewPassword;

  @override
  Future<Result<AuthSession>> login(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> requestPasswordReset(String email) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> resetPassword(String token, String newPassword) async {
    capturedToken = token;
    capturedNewPassword = newPassword;
    return nextResult!;
  }
}

void main() {
  group('ResetPasswordUseCase', () {
    test('delegates to the repository with the given token and new password', () async {
      final repository = _FakeAuthRepository()..nextResult = const Result.success(null);
      final useCase = ResetPasswordUseCase(repository);

      final result = await useCase('token-123', 'novaSenha456');

      expect(repository.capturedToken, 'token-123');
      expect(repository.capturedNewPassword, 'novaSenha456');
      expect(result.isSuccess, isTrue);
    });

    test('propagates a failure result from the repository', () async {
      final repository = _FakeAuthRepository()
        ..nextResult = const Result.failure('Token inválido ou expirado.');
      final useCase = ResetPasswordUseCase(repository);

      final result = await useCase('token-invalido', 'novaSenha456');

      expect(result.isSuccess, isFalse);
      expect((result as Failure<void>).message, 'Token inválido ou expirado.');
    });
  });
}
