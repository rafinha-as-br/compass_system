import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/clients/route_api_client.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/features/travels/data/datasources/route_data_source.dart';
import 'package:routecraft_app/features/travels/data/repositories/route_repository_impl.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';

RouteRepositoryImpl _repositoryWith(MockClient mockClient) {
  final httpClient = HttpApiClient.forTesting(mockClient);
  final dataSource = RouteDataSource(
    client: RouteApiClient(httpClient),
    getToken: () async => 'test-token',
  );
  return RouteRepositoryImpl(dataSource: dataSource);
}

RoutePlan _routePlan() => RoutePlan(
      domainId: 'local-route',
      backEndId: 'r1',
      startDate: DateTime(2025, 8, 1),
      endDate: DateTime(2025, 8, 15),
      startLocation: 'São Paulo',
      destination: 'Lisbon',
      interestsList: const [],
    );

void main() {
  group('RouteRepositoryImpl.updateRoute', () {
    test('returns Success with the updated RoutePlan on a 200 response', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(
          jsonEncode({
            'id': 'r1',
            'startDate': '2025-08-01T00:00:00.000Z',
            'finishDate': '2025-08-20T00:00:00.000Z',
            'startLocation': 'São Paulo',
            'destination': 'Porto',
            'interestPoints': <Map<String, dynamic>>[],
          }),
          200,
        );
      }));

      final result = await repository.updateRoute('t1', _routePlan());

      expect(result.isSuccess, isTrue);
      expect((result as Success<RoutePlan>).data.destination, 'Porto');
    });

    test('returns Failure with the server message when the travel does not exist', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(jsonEncode({'message': 'Viagem não encontrada'}), 404);
      }));

      final result = await repository.updateRoute('missing', _routePlan());

      expect(result.isSuccess, isFalse);
      expect((result as Failure<RoutePlan>).message, 'Viagem não encontrada');
    });

    test('returns a connectivity Failure on a network error', () async {
      final repository = _repositoryWith(MockClient((request) async {
        throw http.ClientException('connection refused');
      }));

      final result = await repository.updateRoute('t1', _routePlan());

      expect(result.isSuccess, isFalse);
      expect((result as Failure<RoutePlan>).isConnectivityError, isTrue);
    });
  });
}
