import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/features/travels/data/dtos/itinerary_step_dto.dart';
import 'package:routecraft_app/features/travels/domain/entities/itinerary_step.dart';

void main() {
  group('ItineraryStepDTO.fromJson polymorphic dispatch', () {
    test('type "placeholder" deserializes to PlaceholderStepDTO without losing description', () {
      final dto = ItineraryStepDTO.fromJson({
        'id': 's1',
        'type': 'placeholder',
        'title': 'Slot',
        'description': 'Not decided yet',
        'startDate': '2026-01-01T00:00:00.000Z',
        'finishDate': '2026-01-02T00:00:00.000Z',
        'finished': false,
      });

      expect(dto, isA<PlaceholderStepDTO>());
      expect((dto as PlaceholderStepDTO).description, 'Not decided yet');
      expect(dto.toDomain(), isA<PlaceholderStep>());
    });

    test('type "stop" deserializes to StopDTO with experiences preserved', () {
      final dto = ItineraryStepDTO.fromJson({
        'id': 's2',
        'type': 'stop',
        'title': 'Belém Tower',
        'name': 'Belém Tower',
        'description': 'UNESCO site',
        'experiences': ['photography', 'sightseeing'],
        'startDate': '2026-01-01T00:00:00.000Z',
        'finishDate': '2026-01-01T12:00:00.000Z',
        'finished': true,
      });

      expect(dto, isA<StopDTO>());
      final stop = (dto as StopDTO);
      expect(stop.experiences, ['photography', 'sightseeing']);
      final domain = stop.toDomain() as Stop;
      expect(domain.experiences, ['photography', 'sightseeing']);
      expect(domain.finished, isTrue);
    });

    test('type "hosting" deserializes to HostingDTO with check-in/check-out dates', () {
      final dto = ItineraryStepDTO.fromJson({
        'id': 's3',
        'type': 'hosting',
        'title': 'Hotel Avenida',
        'name': 'Hotel Avenida Palace',
        'address': 'Rua 1 de Dezembro 123',
        'checkIn': '2026-01-01T15:00:00.000Z',
        'checkOut': '2026-01-10T12:00:00.000Z',
        'startDate': '2026-01-01T00:00:00.000Z',
        'finishDate': '2026-01-10T00:00:00.000Z',
        'finished': false,
      });

      expect(dto, isA<HostingDTO>());
      final hosting = (dto as HostingDTO);
      expect(hosting.address, 'Rua 1 de Dezembro 123');
      final domain = hosting.toDomain() as Hosting;
      expect(domain.checkIn, DateTime.parse('2026-01-01T15:00:00.000Z'));
    });

    test('type "travel_segment" deserializes to TravelSegmentDTO with a nested transport', () {
      final dto = ItineraryStepDTO.fromJson({
        'id': 's4',
        'type': 'travel_segment',
        'title': 'Flight to Lisbon',
        'startPoint': 'GRU',
        'finishPoint': 'LIS',
        'transport': {
          'id': 't1',
          'type': 'airplane',
          'flightNumber': 'TP045',
          'companyName': 'TAP Air Portugal',
          'flightDate': '2026-01-01T10:00:00.000Z',
          'departureGate': 'A12',
          'departureAirport': 'GRU',
          'arrivalAirport': 'LIS',
        },
        'startDate': '2026-01-01T10:00:00.000Z',
        'finishDate': '2026-01-01T22:00:00.000Z',
        'finished': false,
      });

      expect(dto, isA<TravelSegmentDTO>());
      final segment = dto as TravelSegmentDTO;
      final domain = segment.toDomain() as TravelSegment;
      expect(domain.transport.runtimeType.toString(), 'Airplane');
      expect(domain.startPoint, 'GRU');
    });

    test('an unknown type degrades to a placeholder instead of throwing', () {
      final dto = ItineraryStepDTO.fromJson({
        'id': 's5',
        'type': 'something_new',
        'title': 'Mystery step',
        'startDate': '2026-01-01T00:00:00.000Z',
        'finishDate': '2026-01-02T00:00:00.000Z',
        'finished': false,
      });

      expect(dto, isA<PlaceholderStepDTO>());
    });
  });

  group('ItineraryStepDTO round trip', () {
    test('toJson output type matches the original discriminator for each subtype', () {
      final cases = <Map<String, dynamic>>[
        {
          'id': 's1',
          'type': 'placeholder',
          'title': 'Slot',
          'description': 'x',
          'startDate': '2026-01-01T00:00:00.000Z',
          'finishDate': '2026-01-02T00:00:00.000Z',
          'finished': false,
        },
        {
          'id': 's2',
          'type': 'stop',
          'title': 'Stop',
          'name': 'x',
          'description': 'x',
          'experiences': <String>[],
          'startDate': '2026-01-01T00:00:00.000Z',
          'finishDate': '2026-01-02T00:00:00.000Z',
          'finished': false,
        },
      ];

      for (final json in cases) {
        final dto = ItineraryStepDTO.fromJson(json);
        expect(dto.toJson()['type'], json['type']);
      }
    });
  });
}
