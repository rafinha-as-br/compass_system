import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/forms/field_state.dart';

void main() {
  test('passing error: null clears a previous error, so a corrected field is valid again', () {
    const wrong = FieldState<int>(value: 1, error: 'bad', isTouched: true);

    final fixed = wrong.copyWith(value: 2, error: null);

    expect(fixed.error, isNull);
    expect(fixed.isValid, isTrue);
  });

  test('omitting error keeps the current error', () {
    const wrong = FieldState<int>(value: 1, error: 'bad');

    expect(wrong.copyWith(isTouched: true).error, 'bad');
  });
}
