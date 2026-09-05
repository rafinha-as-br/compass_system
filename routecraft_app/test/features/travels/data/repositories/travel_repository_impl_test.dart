import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/clients/travel_api_client.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/features/travels/data/datasources/travel_data_source.dart';
import 'package:routecraft_app/features/travels/data/repositories/travel_repository_impl.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';

Map<String, dynamic> _travelJson({String id = 't1'}) => {
      'id': id,
      'clientName': 'Maria Silva',
      'travelName': 'Lisbon 2025',
      'travelStatus': 'route_created',
      'routePlan': {
        'id': 'r1',
        'startDate': '2025-08-01T00:00:00.000Z',
        'finishDate': '2025-08-15T00:00:00.000Z',
        'startLocation': 'São Paulo',
        'destination': 'Lisbon',
        'interestPoints': <Map<String, dynamic>>[],
      },
      'itinerary': null,
      'participants': <Map<String, dynamic>>[],
    };

TravelRepositoryImpl _repositoryWith(MockClient mockClient) {
  final httpClient = HttpApiClient.forTesting(mockClient);
  final dataSource = TravelDataSource(
    client: TravelApiClient(httpClient),
    getToken: () async => 'test-token',
  );
  return TravelRepositoryImpl(dataSource: dataSource);
}

Travel _newTravel() => Travel(
      domainId: 'local-1',
      backEndId: null,
      clientName: 'Maria Silva',
      travelName: 'Lisbon 2025',
      travelStatus: TravelStatus.routeCreated,
      participantsList: const [],
      routePlan: RoutePlan(
        domainId: 'local-route',
        backEndId: null,
        startDate: DateTime(2025, 8, 1),
        endDate: DateTime(2025, 8, 15),
        startLocation: 'São Paulo',
        destination: 'Lisbon',
        interestsList: const [],
      ),
    );

void main() {
  group('TravelRepositoryImpl.getTravel', () {
    test('returns Success with the mapped Travel on a 200 response', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(jsonEncode(_travelJson()), 200);
      }));

      final result = await repository.getTravel('t1');

      expect(result.isSuccess, isTrue);
      expect((result as Success<Travel>).data.clientName, 'Maria Silva');
    });

    test('returns Failure with the server message on a 404 response', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(jsonEncode({'message': 'Viagem não encontrada'}), 404);
      }));

      final result = await repository.getTravel('missing');

      expect(result.isSuccess, isFalse);
      expect((result as Failure<Travel>).message, 'Viagem não encontrada');
    });

    test('returns a connectivity Failure on a network error', () async {
      final repository = _repositoryWith(MockClient((request) async {
        throw http.ClientException('connection refused');
      }));

      final result = await repository.getTravel('t1');

      expect(result.isSuccess, isFalse);
      expect((result as Failure<Travel>).isConnectivityError, isTrue);
    });
  });

  group('TravelRepositoryImpl.getTravelsForClient', () {
    test('returns Success with every travel from the raw JSON array response', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(jsonEncode([_travelJson(id: 't1'), _travelJson(id: 't2')]), 200);
      }));

      final result = await repository.getTravelsForClient('Maria Silva');

      expect(result.isSuccess, isTrue);
      expect((result as Success<List<Travel>>).data, hasLength(2));
    });

    test('returns a connectivity Failure on a network error', () async {
      final repository = _repositoryWith(MockClient((request) async {
        throw http.ClientException('connection refused');
      }));

      final result = await repository.getTravelsForClient('Maria Silva');

      expect(result.isSuccess, isFalse);
      expect((result as Failure<List<Travel>>).isConnectivityError, isTrue);
    });
  });

  group('TravelRepositoryImpl.createTravel', () {
    test('returns Success with the backend-assigned id on a 200 response', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(jsonEncode(_travelJson(id: 'assigned-id')), 200);
      }));

      final result = await repository.createTravel(_newTravel());

      expect(result.isSuccess, isTrue);
      expect((result as Success<Travel>).data.backEndId, 'assigned-id');
    });

    test('returns Failure with the server message on a 400 response', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(jsonEncode({'message': 'Dados inválidos'}), 400);
      }));

      final result = await repository.createTravel(_newTravel());

      expect(result.isSuccess, isFalse);
      expect((result as Failure<Travel>).message, 'Dados inválidos');
    });
  });
}
