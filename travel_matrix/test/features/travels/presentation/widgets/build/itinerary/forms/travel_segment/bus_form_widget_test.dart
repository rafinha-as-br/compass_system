import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/transports_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/forms/travel_segment/bus_form_widget.dart';
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

BusViewModel _bus() {
  return TransportViewModel.newBus(
    travelNumber: '123',
    travelCompany: 'Viação Ipiranga',
    departureGate: '5',
    departureDateTime: DateTime(2026, 10, 1),
    busStationName: 'Terminal Tietê',
    description: 'Trecho principal',
    details: null,
  ) as BusViewModel;
}

void main() {
  testWidgets('selecting a bus station suggestion emits its coordinate', (tester) async {
    BusViewModel? emitted;

    await tester.pumpWidget(_wrap(BusForm(
      busViewModel: _bus(),
      onChanged: (v) => emitted = v,
      fetchSuggestions: (query) async => const [
        PlaceSuggestion(text: 'Terminal Tietê, SP', coordinate: PlaceCoordinate(-23.51, -46.62)),
      ],
    )));

    // Order: travelNumber(0), travelCompany(1), departureGate(2),
    // departureDateTime(3, date picker), busStationName(4).
    final busStationField = find.byType(TextField).at(4);
    await tester.enterText(busStationField, 'Tietê');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Terminal Tietê'));
    await tester.pump();

    expect(emitted, isNotNull);
    expect(emitted!.busStationName, 'Terminal Tietê, SP');
    expect(emitted!.busStationCoordinate, const PlaceCoordinate(-23.51, -46.62));
  });

  testWidgets('typing free text over the bus station clears its coordinate', (tester) async {
    BusViewModel? emitted;

    await tester.pumpWidget(_wrap(BusForm(
      busViewModel: _bus(),
      onChanged: (v) => emitted = v,
      fetchSuggestions: (query) async => const [],
    )));

    final busStationField = find.byType(TextField).at(4);
    await tester.enterText(busStationField, 'Estação digitada à mão');
    await tester.pump();

    expect(emitted, isNotNull);
    expect(emitted!.busStationCoordinate, isNull);
  });
}
