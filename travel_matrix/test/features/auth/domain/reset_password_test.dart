import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/auth/domain/auth_repository.dart';
import 'package:travel_matrix/features/auth/domain/entities/auth_session.dart';
import 'package:travel_matrix/features/auth/domain/reset_password.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.errorToThrow});

  final Object? errorToThrow;
  String? lastToken;
  String? lastNewPassword;

  @override
  Future<AuthSession> login(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    throw UnimplementedError();
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    lastToken = token;
    lastNewPassword = newPassword;
    if (errorToThrow != null) throw errorToThrow!;
  }
}

void main() {
  group('ResetPassword', () {
    test('delega o token e a nova senha para o repositório', () async {
      final repository = _FakeAuthRepository();
      final resetPassword = ResetPassword(repository);

      await resetPassword('token-123', 'novaSenha456');

      expect(repository.lastToken, 'token-123');
      expect(repository.lastNewPassword, 'novaSenha456');
    });

    test('propaga a exceção lançada pelo repositório sem mascarar', () async {
      final repository = _FakeAuthRepository(
        errorToThrow: StateError('Token inválido ou expirado.'),
      );
      final resetPassword = ResetPassword(repository);

      expect(
        () => resetPassword('token-invalido', 'novaSenha456'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
