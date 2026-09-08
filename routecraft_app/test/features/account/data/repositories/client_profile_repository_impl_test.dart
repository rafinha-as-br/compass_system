import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/clients/client_user_api_client.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/features/account/data/datasources/client_profile_data_source.dart';
import 'package:routecraft_app/features/account/data/repositories/client_profile_repository_impl.dart';
import 'package:routecraft_app/features/account/domain/entities/client_profile.dart';

Map<String, dynamic> _profileJson({String id = '1', int? age = 30}) => {
      'id': id,
      'name': 'Maria Cliente',
      'cpf': '12345678900',
      'sex': 'F',
      'age': age,
      'phoneNumber': '11999998888',
      'email': 'maria@email.com',
      'isActive': true,
    };

ClientProfileRepositoryImpl _repositoryWith(MockClient mockClient) {
  final httpClient = HttpApiClient.forTesting(mockClient);
  final dataSource = ClientProfileDataSource(
    client: ClientUserApiClient(httpClient),
    getToken: () async => 'test-token',
  );
  return ClientProfileRepositoryImpl(dataSource: dataSource);
}

const _profile = ClientProfile(
  id: '1',
  name: 'Maria Cliente',
  cpf: '12345678900',
  phoneNumber: '11999998888',
  email: 'maria@email.com',
  age: 30,
  sex: 'F',
);

void main() {
  group('ClientProfileRepositoryImpl.getCurrentUser', () {
    test('returns Success with the mapped profile, including age, on a 200 response', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(jsonEncode(_profileJson()), 200);
      }));

      final result = await repository.getCurrentUser();

      expect(result.isSuccess, isTrue);
      expect((result as Success<ClientProfile>).data.age, 30);
      expect(result.data.name, 'Maria Cliente');
    });

    test('returns Failure with the server message on a 401 response', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(jsonEncode({'message': 'Não autorizado'}), 401);
      }));

      final result = await repository.getCurrentUser();

      expect(result.isSuccess, isFalse);
      expect((result as Failure<ClientProfile>).message, 'Não autorizado');
    });

    test('returns a connectivity Failure on a network error', () async {
      final repository = _repositoryWith(MockClient((request) async {
        throw http.ClientException('connection refused');
      }));

      final result = await repository.getCurrentUser();

      expect(result.isSuccess, isFalse);
      expect((result as Failure<ClientProfile>).isConnectivityError, isTrue);
    });
  });

  group('ClientProfileRepositoryImpl.updateUser', () {
    test('returns Success with the updated age on a 200 response', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(jsonEncode({'status': 'success', 'data': _profileJson(age: 42)}), 200);
      }));

      final result = await repository.updateUser(_profile.copyWith(age: 42));

      expect(result.isSuccess, isTrue);
      expect((result as Success<ClientProfile>).data.age, 42);
    });

    test('returns Failure with the server message on a 400 response', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(jsonEncode({'message': 'Dados inválidos'}), 400);
      }));

      final result = await repository.updateUser(_profile);

      expect(result.isSuccess, isFalse);
      expect((result as Failure<ClientProfile>).message, 'Dados inválidos');
    });
  });

  group('ClientProfileRepositoryImpl.resetPassword', () {
    test('returns Success on a 200 response', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(jsonEncode({'status': 'success', 'message': 'Password reset successfully.'}), 200);
      }));

      final result = await repository.resetPassword('1');

      expect(result.isSuccess, isTrue);
    });

    test('returns Failure with the server message on a 404 response', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(jsonEncode({'message': 'Usuário não encontrado'}), 404);
      }));

      final result = await repository.resetPassword('missing');

      expect(result.isSuccess, isFalse);
      expect((result as Failure<void>).message, 'Usuário não encontrado');
    });
  });
}
