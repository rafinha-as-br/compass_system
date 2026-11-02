import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/travels/data/dtos/route_dto.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';

void main() {
  group('InterestPointDTO observation (CPS-180)', () {
    test('fromJson reads the observation and defaults to empty for legacy points', () {
      final withNote = InterestPointDTO.fromJson({'id': 'i1', 'name': 'Torre', 'observation': 'Chegar cedo'});
      final legacy = InterestPointDTO.fromJson({'id': 'i2', 'name': 'Alfama'});

      expect(withNote.observation, 'Chegar cedo');
      expect(legacy.observation, '');
    });

    test('round trip: domain -> DTO -> json -> DTO -> domain keeps the observation', () {
      final point = InterestPoint(
        domainId: 'local',
        backEndId: 'i1',
        name: 'Torre',
        description: '',
        observation: 'Chegar cedo',
      );

      final json = InterestPointDTO.fromDomain(interestPoint: point).toJson();
      final roundTripped = InterestPointDTO.fromJson(json).toDomain();

      expect(json['observation'], 'Chegar cedo');
      expect(roundTripped.observation, 'Chegar cedo');
    });
  });
}
