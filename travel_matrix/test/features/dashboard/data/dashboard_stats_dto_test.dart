import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/dashboard/data/dtos/dashboard_stats_dto.dart';

void main() {
  group('DashboardStatsDto', () {
    test('fromJson maps top-level KPIs and nested lists', () {
      final dto = DashboardStatsDto.fromJson({
        'totalTravels': 12,
        'completedItineraries': 7,
        'pendingItineraries': 5,
        'activeClients': 9,
        'recentTravels': [
          {
            'id': '1',
            'clientName': 'Maria Silva',
            'travelName': 'Litoral Norte',
            'travelStatus': 'itinerary_created',
            'itinerary': {},
            'routePlan': {
              'startLocation': 'São Paulo',
              'destination': 'Ubatuba',
              'startDate': '2026-08-01',
            },
          },
        ],
        'activeClientsList': [
          {
            'id': '1',
            'name': 'Maria Silva',
            'email': 'maria@compass.com',
            'phoneNumber': '11999999999',
          },
        ],
      });

      expect(dto.totalTravels, 12);
      expect(dto.completedItineraries, 7);
      expect(dto.pendingItineraries, 5);
      expect(dto.activeClients, 9);
      expect(dto.recentTravels, hasLength(1));
      expect(dto.activeClientsList, hasLength(1));

      final travel = dto.recentTravels.single;
      expect(travel.id, '1');
      // A API não expõe um clientId de verdade (sem FK no backend) — o
      // campo "cliente" da Travel é sempre o nome, nunca um ID.
      expect(travel.clientName, 'Maria Silva');
      expect(travel.destination, 'Ubatuba');
      expect(travel.startLocation, 'São Paulo');
      expect(travel.status, 'itinerary_created');
      expect(travel.hasItinerary, isTrue);

      final client = dto.activeClientsList.single;
      expect(client.name, 'Maria Silva');
      expect(client.email, 'maria@compass.com');
    });

    test('fromJson defaults missing fields to empty/zero values', () {
      final dto = DashboardStatsDto.fromJson(const {});

      expect(dto.totalTravels, 0);
      expect(dto.recentTravels, isEmpty);
      expect(dto.activeClientsList, isEmpty);
    });

    test('fromJson defaults travel status to route_created and hasItinerary to false '
        'when the fields are absent', () {
      final dto = DashboardStatsDto.fromJson({
        'recentTravels': [
          {'id': '1', 'clientName': 'Sem Roteiro'},
        ],
      });

      final travel = dto.recentTravels.single;
      expect(travel.status, 'route_created');
      expect(travel.hasItinerary, isFalse);
    });

    test('round-trips fromJson -> toDomain without losing data', () {
      final dto = DashboardStatsDto.fromJson({
        'totalTravels': 3,
        'completedItineraries': 1,
        'pendingItineraries': 2,
        'activeClients': 4,
        'recentTravels': const [],
        'activeClientsList': const [],
      });

      final domain = dto.toDomain();

      expect(domain.totalTravels, dto.totalTravels);
      expect(domain.completedItineraries, dto.completedItineraries);
      expect(domain.pendingItineraries, dto.pendingItineraries);
      expect(domain.activeClients, dto.activeClients);
    });
  });
}
