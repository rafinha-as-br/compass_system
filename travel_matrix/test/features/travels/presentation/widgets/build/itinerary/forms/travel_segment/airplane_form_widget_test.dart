import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/transports_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/forms/travel_segment/airplane_form_widget.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/models/place_suggestion.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

AirplaneViewModel _airplane() {
  return TransportViewModel.newAirplane(
    flightNumber: 'AZ123',
    flightCompany: 'Azul',
    flightDate: DateTime(2026, 10, 1),
    departureGate: 'A1',
    departureAirport: 'GRU',
    arrivalAirport: 'LIS',
  ) as AirplaneViewModel;
}

void main() {
  testWidgets('selecting a departure airport suggestion emits its coordinate', (tester) async {
    AirplaneViewModel? emitted;

    await tester.pumpWidget(_wrap(AirplaneForm(
      airplaneViewModel: _airplane(),
      onChanged: (v) => emitted = v,
      fetchSuggestions: (query) async => const [
        PlaceSuggestion(text: 'Aeroporto de Guarulhos, SP', coordinate: PlaceCoordinate(-23.43, -46.47)),
      ],
    )));

    // Order: flightNumber(0), flightCompany(1), flightDate(2, date picker
    // TextField), departureGate(3), departureAirport(4), arrivalAirport(5).
    final departureField = find.byType(TextField).at(4);
    await tester.enterText(departureField, 'Guaru');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aeroporto de Guarulhos'));
    await tester.pump();

    expect(emitted, isNotNull);
    expect(emitted!.departureAirport, 'Aeroporto de Guarulhos, SP');
    expect(emitted!.departureAirportCoordinate, const PlaceCoordinate(-23.43, -46.47));
  });

  testWidgets('typing free text over the arrival airport clears its coordinate', (tester) async {
    AirplaneViewModel? emitted;

    await tester.pumpWidget(_wrap(AirplaneForm(
      airplaneViewModel: _airplane(),
      onChanged: (v) => emitted = v,
      fetchSuggestions: (query) async => const [],
    )));

    final arrivalField = find.byType(TextField).at(5);
    await tester.enterText(arrivalField, 'Aeroporto digitado à mão');
    await tester.pump();

    expect(emitted, isNotNull);
    expect(emitted!.arrivalAirportCoordinate, isNull);
  });
}
