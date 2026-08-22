import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/users/domain/entities/user_stats.dart';

void main() {
  test('accepts non-negative counts', () {
    final stats = UserStats(totalTravels: 3, uniqueDestinationsCount: 2);

    expect(stats.totalTravels, 3);
    expect(stats.uniqueDestinationsCount, 2);
  });

  test('rejects a negative totalTravels', () {
    expect(
      () => UserStats(totalTravels: -1, uniqueDestinationsCount: 0),
      throwsA(isA<AssertionError>()),
    );
  });

  test('rejects a negative uniqueDestinationsCount', () {
    expect(
      () => UserStats(totalTravels: 0, uniqueDestinationsCount: -1),
      throwsA(isA<AssertionError>()),
    );
  });
}
