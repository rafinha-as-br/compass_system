import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/auth/domain/entities/auth_session.dart';
import 'package:routecraft_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:routecraft_app/features/auth/domain/usecases/login_usecase.dart';

class _FakeAuthRepository implements AuthRepository {
  Result<AuthSession>? nextResult;
  String? capturedEmail;
  String? capturedPassword;

  @override
  Future<Result<AuthSession>> login(String email, String password) async {
    capturedEmail = email;
    capturedPassword = password;
    return nextResult!;
  }

  @override
  Future<Result<void>> requestPasswordReset(String email) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> resetPassword(String token, String newPassword) async {
    throw UnimplementedError();
  }
}

void main() {
  group('LoginUseCase', () {
    test('delegates to the repository with the given credentials', () async {
      final repository = _FakeAuthRepository()
        ..nextResult = const Result.success(
          AuthSession(token: 't', email: 'a@b.com'),
        );
      final useCase = LoginUseCase(repository);

      final result = await useCase('a@b.com', 'secret');

      expect(repository.capturedEmail, 'a@b.com');
      expect(repository.capturedPassword, 'secret');
      expect(result.isSuccess, isTrue);
    });

    test('propagates a failure result from the repository', () async {
      final repository = _FakeAuthRepository()
        ..nextResult = const Result.failure('E-mail ou senha incorretos.');
      final useCase = LoginUseCase(repository);

      final result = await useCase('a@b.com', 'wrong');

      expect(result.isSuccess, isFalse);
      expect((result as Failure<AuthSession>).message, 'E-mail ou senha incorretos.');
    });
  });
}
