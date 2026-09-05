import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/features/travels/data/dtos/travel_dto.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';

Map<String, dynamic> _travelJson({Object? itinerary}) => {
      'id': 't1',
      'clientName': 'Maria Silva',
      'travelName': 'Lisbon 2025',
      'travelStatus': 'route_created',
      'routePlan': {
        'id': 'r1',
        'startDate': '2025-08-01T00:00:00.000Z',
        'finishDate': '2025-08-15T00:00:00.000Z',
        'startLocation': 'São Paulo',
        'destination': 'Lisbon',
        'interestPoints': [
          {'id': 'ip1', 'name': 'Belém Tower', 'description': 'Historic tower'},
        ],
      },
      'itinerary': itinerary,
      'participants': [
        {'id': 'p1', 'name': 'Maria Silva', 'age': '34', 'sex': 'F'},
      ],
      'events': null,
    };

void main() {
  group('TravelDTO.fromJson', () {
    test('maps every field, including a null itinerary', () {
      final dto = TravelDTO.fromJson(_travelJson());

      expect(dto.id, 't1');
      expect(dto.clientName, 'Maria Silva');
      expect(dto.travelStatus, 'route_created');
      expect(dto.routePlan.startLocation, 'São Paulo');
      expect(dto.routePlan.interestsList, hasLength(1));
      expect(dto.participants, hasLength(1));
      expect(dto.itinerary, isNull);
    });

    test('maps a non-null itinerary with its steps', () {
      final dto = TravelDTO.fromJson(_travelJson(itinerary: {
        'id': 'it1',
        'agentName': 'Carlos Agent',
        'steps': [
          {
            'id': 's1',
            'type': 'stop',
            'title': 'Visit',
            'name': 'x',
            'description': 'x',
            'experiences': <String>[],
            'startDate': '2025-08-03T09:00:00.000Z',
            'finishDate': '2025-08-03T12:00:00.000Z',
            'finished': false,
          },
        ],
      }));

      expect(dto.itinerary, isNotNull);
      expect(dto.itinerary!.itinerarySteps, hasLength(1));
    });
  });

  group('TravelDTO.toDomain / fromDomain round trip', () {
    test('preserves clientName, travelName, status and route plan through a full round trip', () {
      final dto = TravelDTO.fromJson(_travelJson());
      final travel = dto.toDomain();

      expect(travel.clientName, 'Maria Silva');
      expect(travel.travelName, 'Lisbon 2025');
      expect(travel.travelStatus, TravelStatus.routeCreated);
      expect(travel.hasItinerary, isFalse);
      expect(travel.routePlan.interestsList.single.name, 'Belém Tower');

      final backToDto = TravelDTO.fromDomain(travel);
      expect(backToDto.id, 't1');
      expect(backToDto.clientName, 'Maria Silva');
      expect(backToDto.travelStatus, 'route_created');
    });

    test('fromDomain sends null nested ids for a travel not yet persisted', () {
      final travel = Travel(
        domainId: 'local-1',
        backEndId: null,
        clientName: 'Maria Silva',
        travelName: 'New Trip',
        travelStatus: TravelStatus.routeCreated,
        participantsList: const [],
        routePlan: RoutePlan(
          domainId: 'local-route',
          backEndId: null,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 10),
          startLocation: 'SP',
          destination: 'Lisbon',
          interestsList: const [],
        ),
      );

      final json = TravelDTO.fromDomain(travel).toJson();

      expect(json['id'], isNull);
      expect((json['routePlan'] as Map<String, dynamic>)['id'], isNull);
    });

    test('hasItinerary is true once travelStatus moves past routeCreated', () {
      final dto = TravelDTO.fromJson({..._travelJson(), 'travelStatus': 'itinerary_created'});

      expect(dto.toDomain().hasItinerary, isTrue);
    });
  });
}
