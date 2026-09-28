import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/shared/models/place_suggestion.dart';

void main() {
  group('PlaceCoordinate.tryFromJson', () {
    test('parses a well-formed coordinate', () {
      final result = PlaceCoordinate.tryFromJson({'latitude': -23.5505, 'longitude': -46.6333});
      expect(result, const PlaceCoordinate(-23.5505, -46.6333));
    });

    test('degrades to null instead of throwing on a malformed coordinate', () {
      expect(PlaceCoordinate.tryFromJson({'latitude': null, 'longitude': null}), isNull);
      expect(PlaceCoordinate.tryFromJson({'latitude': -23.5}), isNull);
      expect(PlaceCoordinate.tryFromJson('not a map'), isNull);
      expect(PlaceCoordinate.tryFromJson(null), isNull);
    });
  });
}
