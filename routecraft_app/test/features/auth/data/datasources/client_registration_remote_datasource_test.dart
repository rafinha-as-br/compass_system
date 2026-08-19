import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:routecraft_app/core/network/api_exception.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/features/auth/data/datasources/client_registration_remote_datasource.dart';
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

void main() {
  group('ClientRegistrationRemoteDataSource.register', () {
    test('returns the plain-text confirmation body on success', () async {
      final client = HttpApiClient.forTesting(MockClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['name'], 'John Doe');
        expect(body['age'], 30);
        return http.Response('Cliente cadastrado com sucesso no Compass System!', 200);
      }));
      final dataSource = ClientRegistrationRemoteDataSource(client);

      final message = await dataSource.register(_registration);

      expect(message, 'Cliente cadastrado com sucesso no Compass System!');
    });

    test('throws ApiException with the duplicate e-mail message on 400', () async {
      final client = HttpApiClient.forTesting(MockClient((request) async {
        return http.Response(
          jsonEncode({
            'status': 400,
            'error': 'Erro de negócio',
            'message': 'Este e-mail já está cadastrado.',
          }),
          400,
        );
      }));
      final dataSource = ClientRegistrationRemoteDataSource(client);

      expect(
        () => dataSource.register(_registration),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Este e-mail já está cadastrado.',
          ),
        ),
      );
    });
  });
}
