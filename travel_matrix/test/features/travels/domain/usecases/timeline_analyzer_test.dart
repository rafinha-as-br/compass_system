import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/travels/domain/usecases/timeline_analyzer.dart';

void main() {
  group('timelineAnalyzer', () {
    test('returns an empty problem list when given an empty node list', () {
      final problems = timelineAnalyzer(const []);

      expect(problems, isEmpty);
    });
  });
}
