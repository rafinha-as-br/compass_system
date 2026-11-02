import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/editor/itinerary_editor_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/itinerary_steps_view_models.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/transports_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

/// Editor with a wide trip around the step under test (boundary steps on Oct 1 / Oct 31).
ItineraryEditorController _editorWith(String locale, DateTime flightDate) {
  final e = ItineraryEditorController(
    interestPoints: [],
    steps: null,
    l10n: lookupAppLocalizations(Locale(locale)),
  );
  e.updateStep(0, e.stepsList.first.copyWith(
    startDate: DateTime(2025, 10, 1), finishDate: DateTime(2025, 10, 1)));
  e.updateStep(1, e.stepsList.last.copyWith(
    startDate: DateTime(2025, 10, 31), finishDate: DateTime(2025, 10, 31)));
  e.addStep(
    newStep: ItineraryStepViewModel.newTravelSegment(
      title: 'Voo',
      startDate: DateTime(2025, 10, 5),
      finishDate: DateTime(2025, 10, 8),
      position: StepPosition.middle,
      startPoint: 'A',
      finishPoint: 'B',
      transport: TransportViewModel.newAirplane(
        flightNumber: 'AZ1',
        flightCompany: 'Azul',
        flightDate: flightDate,
        departureGate: '1',
        departureAirport: 'GRU',
        arrivalAirport: 'LIS',
      ),
    ),
  );
  return e;
}

void main() {
  test('flight outside the step period explains the cause with the dates (pt)', () {
    final e = _editorWith('pt', DateTime(2025, 10, 15));

    final problems = e.stepsList[1].problems!;
    expect(problems, hasLength(1));
    expect(
      problems.single.description,
      'A data do voo (15/10) está fora do período do step (05/10 a 08/10). '
      'Ajuste a data do voo ou o período do step.',
    );
  });

  test('flight outside the step period explains the cause with the dates (en)', () {
    final e = _editorWith('en', DateTime(2025, 10, 4));

    expect(
      e.stepsList[1].problems!.single.description,
      'The flight date (10/04) is outside the step period (10/05 to 10/08). '
      'Adjust the flight date or the step period.',
    );
  });

  test('flight on the first or last day of the step is not a problem', () {
    expect(_editorWith('pt', DateTime(2025, 10, 5)).stepsList[1].problems, isEmpty);
    expect(_editorWith('pt', DateTime(2025, 10, 8)).stepsList[1].problems, isEmpty);
  });

  test('invalid date names the step and the cause', () {
    final e = _editorWith('en', DateTime(2025, 10, 6));
    e.updateStep(1, e.stepsList[1].copyWith(startDate: DateTime(2025, 10, 9)));

    expect(
      e.stepsList[1].problems!.single.description,
      'The start date of "Voo" is after its end date. Adjust the dates.',
    );
  });
}
