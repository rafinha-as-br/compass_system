import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/travels/domain/usecases/timeline_analyzer.dart';

void main() {
  group('timelineAnalyzer', () {
    test('returns an empty problem list when given an empty node list', () {
      final problems = timelineAnalyzer(const []);

      expect(problems, isEmpty);
    });
  });

  group('stepPeriodAnalyzer', () {
    List<TimelineNode> nodes(DateTime inner) => [
          TimelineNode.instant(domainId: 's', date: DateTime(2025, 10, 5), sequenceIndex: 0),
          TimelineNode.instant(domainId: 's', date: inner, sequenceIndex: 1),
          TimelineNode.instant(domainId: 's', date: DateTime(2025, 10, 8), sequenceIndex: 2),
        ];

    test('dates on the step start and finish days are valid (limits included)', () {
      expect(stepPeriodAnalyzer(nodes(DateTime(2025, 10, 5))), isEmpty);
      expect(stepPeriodAnalyzer(nodes(DateTime(2025, 10, 8, 23, 59))), isEmpty);
      expect(stepPeriodAnalyzer(nodes(DateTime(2025, 10, 6))), isEmpty);
    });

    test('flags a date before the start or after the finish of the step', () {
      for (final d in [DateTime(2025, 10, 4, 23, 59), DateTime(2025, 10, 9)]) {
        final problems = stepPeriodAnalyzer(nodes(d));
        expect(problems.single.type, TimelineProblemType.outsideStepPeriod);
        expect(problems.single.involves('s'), isTrue);
      }
    });
  });
}
