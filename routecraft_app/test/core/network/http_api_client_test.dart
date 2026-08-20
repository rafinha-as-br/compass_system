import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:routecraft_app/core/network/api_exception.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';

void main() {
  group('HttpApiClient', () {
    test('post returns the decoded JSON body on a 2xx response', () async {
      final client = HttpApiClient.forTesting(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.headers['Content-Type'], 'application/json');
          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': {'token': 'abc123'},
              'message': null,
            }),
            200,
          );
        }),
      );

      final result = await client.post('', '/api/auth/login', {
        'email': 'user@example.com',
        'password': 'secret',
      });

      expect(result['status'], 'success');
      expect((result['data'] as Map)['token'], 'abc123');
    });

    test('non-JSON 2xx body (plain text) is wrapped under data', () async {
      final client = HttpApiClient.forTesting(
        MockClient((request) async {
          return http.Response('Cliente cadastrado com sucesso!', 200);
        }),
      );

      final result = await client.post('', '/api/auth/cadastrar/cliente', {});

      expect(result['data'], 'Cliente cadastrado com sucesso!');
    });

    test('throws ApiException with the server message on a 4xx response',
        () async {
      final client = HttpApiClient.forTesting(
        MockClient((request) async {
          return http.Response(
            jsonEncode({
              'status': 400,
              'error': 'Erro de negócio',
              'message': 'Este e-mail já está cadastrado.',
            }),
            400,
          );
        }),
      );

      expect(
        () => client.post('', '/api/auth/cadastrar/cliente', {}),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Este e-mail já está cadastrado.',
          ),
        ),
      );
    });

    test('throws a friendly ApiException when the request throws', () async {
      final client = HttpApiClient.forTesting(
        MockClient((request) async {
          throw http.ClientException('connection refused');
        }),
      );

      expect(
        () => client.get('token', '/api/auth/login'),
        throwsA(isA<ApiException>()),
      );
    });

    test('sends the bearer token header when a token is provided', () async {
      final client = HttpApiClient.forTesting(
        MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer my-token');
          return http.Response('{}', 200);
        }),
      );

      await client.get('my-token', '/api/some/resource');
    });
  });
}
