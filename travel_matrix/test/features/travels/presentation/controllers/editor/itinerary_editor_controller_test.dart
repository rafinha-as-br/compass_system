import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/editor/itinerary_editor_controller.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

ItineraryEditorController _editor({DateTime? end}) => ItineraryEditorController(
      interestPoints: [],
      steps: null,
      l10n: lookupAppLocalizations(const Locale('en')),
      tripStartDate: DateTime(2025, 10, 1),
      tripEndDate: end ?? DateTime(2025, 10, 10),
    );

void main() {
  test('start and finish placeholder steps get distinct default titles', () {
    final editor = _editor();

    expect(editor.stepsList.length, 2);
    expect(
      editor.stepsList[0].title,
      isNot(editor.stepsList[1].title),
      reason:
          'identical default titles make the two boundary steps indistinguishable '
          'in the UI, risking edits landing on the wrong one',
    );
  });

  test('start and finish steps are born with the trip dates, not today', () {
    final editor = _editor();

    expect(editor.stepsList.first.startDate, DateTime(2025, 10, 1));
    expect(editor.stepsList.last.startDate, DateTime(2025, 10, 10));
    expect(editor.stepsList.last.finishDate, DateTime(2025, 10, 10));
  });

  test('new steps continue from the previous step end, one day long', () {
    final editor = _editor()..addNewStep()..addNewStep();

    final middle = editor.stepsList.sublist(1, 3);
    expect(middle[0].startDate, DateTime(2025, 10, 1));
    expect(middle[0].finishDate, DateTime(2025, 10, 2));
    expect(middle[1].startDate, DateTime(2025, 10, 2));
    expect(middle[1].finishDate, DateTime(2025, 10, 3));
  });

  test('new steps never go past the trip end', () {
    final editor = _editor(end: DateTime(2025, 10, 2))
      ..addNewStep()
      ..addNewStep();

    final last = editor.stepsList[2];
    expect(last.startDate, DateTime(2025, 10, 2));
    expect(last.finishDate, DateTime(2025, 10, 2));
  });
}
