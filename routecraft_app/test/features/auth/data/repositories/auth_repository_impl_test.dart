import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:routecraft_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:routecraft_app/features/auth/domain/entities/auth_session.dart';

AuthRepositoryImpl _repositoryWith(MockClient mockClient) {
  final client = HttpApiClient.forTesting(mockClient);
  return AuthRepositoryImpl(AuthRemoteDataSource(client));
}

void main() {
  group('AuthRepositoryImpl.login', () {
    test('returns Success with the mapped AuthSession on a 200 response', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(
          jsonEncode({
            'status': 'success',
            'data': {
              'token': 'jwt-token',
              'userId': '1',
              'name': 'John',
              'email': 'john@example.com',
              'userType': 'CLIENTE',
            },
            'message': null,
          }),
          200,
        );
      }));

      final result = await repository.login('john@example.com', 'secret');

      expect(result.isSuccess, isTrue);
      final session = (result as Success<AuthSession>).data;
      expect(session.token, 'jwt-token');
      expect(session.userType, 'CLIENTE');
    });

    test('returns Failure with the server message on a 400 response', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(
          jsonEncode({
            'status': 400,
            'error': 'Erro de negócio',
            'message': 'E-mail ou senha incorretos.',
          }),
          400,
        );
      }));

      final result = await repository.login('john@example.com', 'wrong');

      expect(result.isSuccess, isFalse);
      expect(
        (result as Failure<AuthSession>).message,
        'E-mail ou senha incorretos.',
      );
    });

    test('returns Failure with a friendly message on a network error', () async {
      final repository = _repositoryWith(MockClient((request) async {
        throw http.ClientException('connection refused');
      }));

      final result = await repository.login('john@example.com', 'secret');

      expect(result.isSuccess, isFalse);
      expect((result as Failure<AuthSession>).message, isNotEmpty);
    });

    test('returns Failure instead of throwing when the response shape is unexpected', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(
          jsonEncode({'status': 'success', 'data': {'token': 'jwt-token'}}),
          200,
        );
      }));

      final result = await repository.login('john@example.com', 'secret');

      expect(result.isSuccess, isFalse);
      expect((result as Failure<AuthSession>).message, isNotEmpty);
    });
  });
}
