import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/features/auth/data/auth_data_source.dart';
import 'package:travel_matrix/features/auth/data/auth_repository_impl.dart';

class _MockAuthDataSource extends Mock implements AuthDataSource {}

void main() {
  late _MockAuthDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    dataSource = _MockAuthDataSource();
    repository = AuthRepositoryImpl(dataSource);
  });

  group('AuthRepositoryImpl.login', () {
    test('returns the mapped AuthSession on a successful response', () async {
      when(() => dataSource.login('agente@matrix.com', 'senha123')).thenAnswer(
        (_) async => {
          'status': 'success',
          'data': {
            'token': 'jwt-token',
            'userId': '1',
            'name': 'Carlos Agente',
            'email': 'agente@matrix.com',
            'userType': 'AGENTE',
          },
          'message': null,
        },
      );

      final session = await repository.login('agente@matrix.com', 'senha123');

      expect(session.token, 'jwt-token');
      expect(session.userType, 'AGENTE');
    });

    // A API agora rejeita um Cliente com credenciais válidas tentando
    // acessar o Travel Matrix (expectedUserType=AGENTE), retornando
    // status "error" com a mensagem de acesso negado — este teste garante
    // que essa resposta é recebida e tratada, não engolida ou mascarada.
    test('throws StateError with the API access-denied message for a non-agent account', () async {
      when(() => dataSource.login('cliente@matrix.com', 'senha123')).thenAnswer(
        (_) async => {
          'status': 'error',
          'data': null,
          'message': 'Acesso negado. Este usuário não tem permissão para acessar esta aplicação.',
        },
      );

      expect(
        () => repository.login('cliente@matrix.com', 'senha123'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'Acesso negado. Este usuário não tem permissão para acessar esta aplicação.',
          ),
        ),
      );
    });

    test('throws StateError with the API message for invalid credentials', () async {
      when(() => dataSource.login('agente@matrix.com', 'senha-errada')).thenAnswer(
        (_) async => {
          'status': 'error',
          'data': null,
          'message': 'E-mail ou senha incorretos.',
        },
      );

      expect(
        () => repository.login('agente@matrix.com', 'senha-errada'),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'E-mail ou senha incorretos.'),
        ),
      );
    });
  });

  group('AuthRepositoryImpl.requestPasswordReset', () {
    test('completa sem erro quando a resposta não tem status "error"', () async {
      when(() => dataSource.requestPasswordReset('agente@matrix.com')).thenAnswer(
        (_) async => {
          'data': 'Se o e-mail informado estiver cadastrado, você receberá instruções...',
        },
      );

      await expectLater(
        repository.requestPasswordReset('agente@matrix.com'),
        completes,
      );
    });

    test('lança StateError com a mensagem da API quando a resposta tem status "error"', () async {
      when(() => dataSource.requestPasswordReset('agente@matrix.com')).thenAnswer(
        (_) async => {
          'status': 'error',
          'data': null,
          'message': 'Erro de rede.',
        },
      );

      expect(
        () => repository.requestPasswordReset('agente@matrix.com'),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'Erro de rede.'),
        ),
      );
    });
  });

  group('AuthRepositoryImpl.resetPassword', () {
    test('completa sem erro quando a resposta não tem status "error"', () async {
      when(() => dataSource.resetPassword('token-123', 'novaSenha456')).thenAnswer(
        (_) async => {'data': 'Senha redefinida com sucesso.'},
      );

      await expectLater(
        repository.resetPassword('token-123', 'novaSenha456'),
        completes,
      );
    });

    test('lança StateError com a mensagem da API para token inválido/expirado', () async {
      when(() => dataSource.resetPassword('token-invalido', 'novaSenha456')).thenAnswer(
        (_) async => {
          'status': 'error',
          'data': null,
          'message': 'Token inválido ou expirado.',
        },
      );

      expect(
        () => repository.resetPassword('token-invalido', 'novaSenha456'),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'Token inválido ou expirado.'),
        ),
      );
    });
  });
}
