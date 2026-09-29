import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/features/travels/data/dtos/route_dto.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/shared/models/place_suggestion.dart';

void main() {
  group('RoutePlanDTO coordinate mapping (CPS-155)', () {
    test('fromJson reads the nested startLocationCoordinate/destinationCoordinate objects', () {
      final dto = RoutePlanDTO.fromJson({
        'id': 'r1',
        'startDate': '2026-10-12T00:00:00.000Z',
        'finishDate': '2026-10-19T00:00:00.000Z',
        'startLocation': 'São Paulo',
        'destination': 'Paraty',
        'interestPoints': [],
        'startLocationCoordinate': {'latitude': -23.5505, 'longitude': -46.6333},
        'destinationCoordinate': {'latitude': -23.2178, 'longitude': -44.7131},
      });

      expect(dto.startLocationCoordinate, const PlaceCoordinate(-23.5505, -46.6333));
      expect(dto.destinationCoordinate, const PlaceCoordinate(-23.2178, -44.7131));
    });

    test('fromJson tolerates a missing/null coordinate — legacy routes', () {
      final dto = RoutePlanDTO.fromJson({
        'id': 'r1',
        'startDate': '2026-10-12T00:00:00.000Z',
        'finishDate': '2026-10-19T00:00:00.000Z',
        'startLocation': 'São Paulo',
        'destination': 'Paraty',
        'interestPoints': [],
      });

      expect(dto.startLocationCoordinate, isNull);
      expect(dto.destinationCoordinate, isNull);
    });

    test('round trip: domain -> DTO -> json -> DTO -> domain preserves the coordinate', () {
      final original = RoutePlan(
        domainId: 'local-1',
        backEndId: 'r1',
        startDate: DateTime.utc(2026, 10, 12),
        endDate: DateTime.utc(2026, 10, 19),
        startLocation: 'São Paulo',
        destination: 'Paraty',
        interestsList: [
          InterestPoint(
            domainId: 'local-i1',
            backEndId: 'i1',
            name: 'Trilha do Sono',
            description: '',
            coordinate: const PlaceCoordinate(-23.2, -44.7),
          ),
        ],
        startLocationCoordinate: const PlaceCoordinate(-23.5505, -46.6333),
        destinationCoordinate: const PlaceCoordinate(-23.2178, -44.7131),
      );

      final roundTripped = RoutePlanDTO.fromJson(RoutePlanDTO.fromDomain(original).toJson()).toDomain();

      expect(roundTripped.startLocationCoordinate, original.startLocationCoordinate);
      expect(roundTripped.destinationCoordinate, original.destinationCoordinate);
      expect(roundTripped.interestsList.single.coordinate, original.interestsList.single.coordinate);
    });

    test('round trip preserves a null coordinate as null, not a default', () {
      final original = RoutePlan(
        domainId: 'local-1',
        backEndId: 'r1',
        startDate: DateTime.utc(2026, 10, 12),
        endDate: DateTime.utc(2026, 10, 19),
        startLocation: 'São Paulo',
        destination: 'Paraty',
        interestsList: const [],
      );

      final roundTripped = RoutePlanDTO.fromJson(RoutePlanDTO.fromDomain(original).toJson()).toDomain();

      expect(roundTripped.startLocationCoordinate, isNull);
      expect(roundTripped.destinationCoordinate, isNull);
    });
  });
}
