import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/auth/domain/auth_repository.dart';
import 'package:travel_matrix/features/auth/domain/entities/auth_session.dart';
import 'package:travel_matrix/features/auth/domain/request_password_reset.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.errorToThrow});

  final Object? errorToThrow;
  String? lastEmail;

  @override
  Future<AuthSession> login(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    lastEmail = email;
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    throw UnimplementedError();
  }
}

void main() {
  group('RequestPasswordReset', () {
    test('delega o e-mail para o repositório', () async {
      final repository = _FakeAuthRepository();
      final requestPasswordReset = RequestPasswordReset(repository);

      await requestPasswordReset('agente@compass.com');

      expect(repository.lastEmail, 'agente@compass.com');
    });

    test('propaga a exceção lançada pelo repositório sem mascarar', () async {
      final repository = _FakeAuthRepository(
        errorToThrow: StateError('An error occurred. Please try again.'),
      );
      final requestPasswordReset = RequestPasswordReset(repository);

      expect(
        () => requestPasswordReset('agente@compass.com'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
