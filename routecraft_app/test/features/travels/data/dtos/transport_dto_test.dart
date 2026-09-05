import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/features/travels/data/dtos/transport_dto.dart';
import 'package:routecraft_app/features/travels/domain/entities/transport.dart';

void main() {
  group('TransportDTO.fromJson polymorphic dispatch', () {
    test('type "rental_car" deserializes to RentalCarDTO', () {
      final dto = TransportDTO.fromJson({
        'id': 'tr1',
        'type': 'rental_car',
        'vehicleModelName': 'Onix',
        'vehicleLicensePlate': 'ABC1D23',
        'companyName': 'Localiza',
        'checkInDate': '2026-01-01T00:00:00.000Z',
        'checkOutDate': '2026-01-05T00:00:00.000Z',
      });

      expect(dto, isA<RentalCarDTO>());
      expect(dto.toDomain(), isA<RentalCar>());
    });

    test('type "bus" deserializes to BusDTO preserving a nullable details field', () {
      final dto = TransportDTO.fromJson({
        'id': 'tr2',
        'type': 'bus',
        'travelNumber': '123',
        'travelCompany': 'Viação X',
        'departureGate': 'B3',
        'departureDateTime': '2026-01-01T08:00:00.000Z',
        'busStationName': 'Terminal Tietê',
        'description': 'Executivo',
        'details': null,
      });

      expect(dto, isA<BusDTO>());
      final bus = dto as BusDTO;
      expect(bus.details, isNull);
      final domain = dto.toDomain() as Bus;
      expect(domain.details, isNull);
    });

    test('type "airplane" deserializes to AirplaneDTO', () {
      final dto = TransportDTO.fromJson({
        'id': 'tr3',
        'type': 'airplane',
        'flightNumber': 'TP045',
        'companyName': 'TAP Air Portugal',
        'flightDate': '2026-01-01T10:00:00.000Z',
        'departureGate': 'A12',
        'departureAirport': 'GRU',
        'arrivalAirport': 'LIS',
      });

      expect(dto, isA<AirplaneDTO>());
      final airplane = dto as AirplaneDTO;
      expect(airplane.flightCompany, 'TAP Air Portugal');
      expect(dto.toDomain(), isA<Airplane>());
    });

    test('an unknown type degrades to a placeholder instead of throwing', () {
      final dto = TransportDTO.fromJson({'id': 'tr4', 'type': 'hoverboard'});

      expect(dto, isA<PlaceholderTransportDTO>());
    });
  });
}
