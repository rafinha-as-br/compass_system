import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/editor/itinerary_editor_controller.dart';

void main() {
  test('start and finish placeholder steps get distinct default titles', () {
    final editor = ItineraryEditorController(interestPoints: [], steps: null);

    expect(editor.stepsList.length, 2);
    expect(
      editor.stepsList[0].title,
      isNot(editor.stepsList[1].title),
      reason:
          'identical default titles make the two boundary steps indistinguishable '
          'in the UI, risking edits landing on the wrong one',
    );
  });
}
