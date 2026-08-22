import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/auth/domain/auth_repository.dart';
import 'package:travel_matrix/features/auth/domain/entities/auth_session.dart';
import 'package:travel_matrix/features/auth/domain/login.dart';

/// Fake escrito à mão em vez de mocktail/mockito: [AuthRepository] tem um
/// único método, então um fake simples é mais direto e não exige adicionar
/// uma dependência de mock só para este caso.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.sessionToReturn, this.errorToThrow});

  final AuthSession? sessionToReturn;
  final Object? errorToThrow;

  String? lastEmail;
  String? lastPassword;

  @override
  Future<AuthSession> login(String email, String password) async {
    lastEmail = email;
    lastPassword = password;
    if (errorToThrow != null) throw errorToThrow!;
    return sessionToReturn!;
  }

  @override
  Future<void> requestPasswordReset(String email) async {}

  @override
  Future<void> resetPassword(String token, String newPassword) async {}
}

void main() {
  group('Login', () {
    test('retorna a AuthSession quando o usuário é um AGENTE', () async {
      final repository = _FakeAuthRepository(
        sessionToReturn: const AuthSession(token: 'abc123', userType: 'AGENTE'),
      );
      final login = Login(repository);

      final result = await login('agente@compass.com', 'senha123');

      expect(result.token, 'abc123');
      expect(result.userType, 'AGENTE');
      expect(repository.lastEmail, 'agente@compass.com');
      expect(repository.lastPassword, 'senha123');
    });

    test('lança StateError quando o usuário não é AGENTE', () async {
      final repository = _FakeAuthRepository(
        sessionToReturn: const AuthSession(token: 'abc123', userType: 'CLIENTE'),
      );
      final login = Login(repository);

      expect(
        () => login('cliente@compass.com', 'senha123'),
        throwsA(isA<StateError>()),
      );
    });

    test('propaga a exceção lançada pelo repositório sem mascarar', () async {
      final repository = _FakeAuthRepository(
        errorToThrow: StateError('Invalid credentials. Please try again.'),
      );
      final login = Login(repository);

      expect(
        () => login('agente@compass.com', 'senha-errada'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
