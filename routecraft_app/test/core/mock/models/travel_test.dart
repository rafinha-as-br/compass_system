import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/mock/mock_repository.dart';

RoutePlan _routePlan() => RoutePlan(
      startDate: DateTime.utc(2026, 1, 10),
      endDate: DateTime.utc(2026, 1, 20),
      startLocation: 'New York',
      destination: 'Tokyo',
      interestsList: const [],
    );

void main() {
  group('Travel', () {
    test('hasItinerary is false when status is routeCreated', () {
      final travel = Travel(
        id: 't1',
        clientId: 'client_1',
        agentId: 'agent_1',
        travelName: 'Trip',
        travelStatus: TravelStatus.routeCreated,
        participantsList: const [],
        routePlan: _routePlan(),
      );

      expect(travel.hasItinerary, isFalse);
    });

    test('hasItinerary is true once status moves past routeCreated', () {
      final travel = Travel(
        id: 't1',
        clientId: 'client_1',
        agentId: 'agent_1',
        travelName: 'Trip',
        travelStatus: TravelStatus.itineraryReady,
        participantsList: const [],
        routePlan: _routePlan(),
      );

      expect(travel.hasItinerary, isTrue);
    });

    test('fromJson parses a well-formed payload', () {
      final json = {
        'id': 't1',
        'clientId': 'client_1',
        'agentId': 'agent_1',
        'travelName': 'Trip',
        'travelStatus': 'inProgress',
        'participantsList': ['client_1'],
        'routePlan': _routePlan().toMap(),
      };

      final travel = Travel.fromJson(json);

      expect(travel.id, 't1');
      expect(travel.travelStatus, TravelStatus.inProgress);
      expect(travel.participantsList, ['client_1']);
      expect(travel.routePlan.destination, 'Tokyo');
    });

    test('fromJson falls back to routeCreated for unknown status', () {
      final json = {
        'id': 't1',
        'clientId': 'client_1',
        'agentId': 'agent_1',
        'travelName': 'Trip',
        'travelStatus': 'not_a_real_status',
        'participantsList': <String>[],
        'routePlan': _routePlan().toMap(),
      };

      final travel = Travel.fromJson(json);

      expect(travel.travelStatus, TravelStatus.routeCreated);
    });
  });
}
