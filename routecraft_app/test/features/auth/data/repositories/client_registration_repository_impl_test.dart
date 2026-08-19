import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/features/auth/data/datasources/client_registration_remote_datasource.dart';
import 'package:routecraft_app/features/auth/data/repositories/client_registration_repository_impl.dart';
import 'package:routecraft_app/features/auth/domain/entities/client_registration.dart';

const _registration = ClientRegistration(
  name: 'John Doe',
  cpf: '12345678900',
  age: 30,
  gender: 'M',
  phone: '11999999999',
  email: 'john@example.com',
  password: 'secret',
);

ClientRegistrationRepositoryImpl _repositoryWith(MockClient mockClient) {
  final client = HttpApiClient.forTesting(mockClient);
  return ClientRegistrationRepositoryImpl(ClientRegistrationRemoteDataSource(client));
}

void main() {
  group('ClientRegistrationRepositoryImpl.register', () {
    test('returns Success with the server confirmation message', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response('Cliente cadastrado com sucesso!', 200);
      }));

      final result = await repository.register(_registration);

      expect(result.isSuccess, isTrue);
    });

    test('returns Failure with the duplicate e-mail message on 400', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(
          jsonEncode({
            'status': 400,
            'error': 'Erro de negócio',
            'message': 'Este e-mail já está cadastrado.',
          }),
          400,
        );
      }));

      final result = await repository.register(_registration);

      expect(result.isSuccess, isFalse);
    });

    test('returns Failure with a friendly message on a network error', () async {
      final repository = _repositoryWith(MockClient((request) async {
        throw http.ClientException('connection refused');
      }));

      final result = await repository.register(_registration);

      expect(result.isSuccess, isFalse);
    });
  });
}
