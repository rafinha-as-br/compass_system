import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/mock/mock_repository.dart';

void main() {
  group('RoutePlan', () {
    test('toMap/fromJson round trip preserves all fields', () {
      final original = RoutePlan(
        startDate: DateTime.utc(2026, 1, 10),
        endDate: DateTime.utc(2026, 1, 20),
        startLocation: 'New York',
        destination: 'Tokyo',
        interestsList: const [
          InterestPoint(id: 'ip1', name: 'Mount Fuji', description: 'Sightseeing'),
        ],
      );

      final restored = RoutePlan.fromJson(original.toMap());

      expect(restored.startDate, original.startDate);
      expect(restored.endDate, original.endDate);
      expect(restored.startLocation, original.startLocation);
      expect(restored.destination, original.destination);
      expect(restored.interestsList.length, 1);
      expect(restored.interestsList.first.id, 'ip1');
      expect(restored.interestsList.first.name, 'Mount Fuji');
      expect(restored.interestsList.first.description, 'Sightseeing');
    });

    test('fromJson handles missing interestsList as empty', () {
      final json = {
        'startDate': DateTime.utc(2026, 1, 10).toIso8601String(),
        'endDate': DateTime.utc(2026, 1, 20).toIso8601String(),
        'startLocation': 'New York',
        'destination': 'Tokyo',
      };

      final restored = RoutePlan.fromJson(json);

      expect(restored.interestsList, isEmpty);
    });
  });
}
