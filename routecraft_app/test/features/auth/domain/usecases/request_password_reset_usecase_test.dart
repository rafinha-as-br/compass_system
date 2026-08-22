import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/auth/domain/entities/auth_session.dart';
import 'package:routecraft_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:routecraft_app/features/auth/domain/usecases/request_password_reset_usecase.dart';

class _FakeAuthRepository implements AuthRepository {
  Result<void>? nextResult;
  String? capturedEmail;

  @override
  Future<Result<AuthSession>> login(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> requestPasswordReset(String email) async {
    capturedEmail = email;
    return nextResult!;
  }

  @override
  Future<Result<void>> resetPassword(String token, String newPassword) async {
    throw UnimplementedError();
  }
}

void main() {
  group('RequestPasswordResetUseCase', () {
    test('delegates to the repository with the given e-mail', () async {
      final repository = _FakeAuthRepository()..nextResult = const Result.success(null);
      final useCase = RequestPasswordResetUseCase(repository);

      final result = await useCase('a@b.com');

      expect(repository.capturedEmail, 'a@b.com');
      expect(result.isSuccess, isTrue);
    });

    test('propagates a failure result from the repository', () async {
      final repository = _FakeAuthRepository()
        ..nextResult = const Result.failure('Não foi possível completar a solicitação.');
      final useCase = RequestPasswordResetUseCase(repository);

      final result = await useCase('a@b.com');

      expect(result.isSuccess, isFalse);
      expect(
        (result as Failure<void>).message,
        'Não foi possível completar a solicitação.',
      );
    });
  });
}
