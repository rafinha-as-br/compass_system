import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/transports_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/forms/travel_segment/rental_car_form_widget.dart';
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

RentalCarViewModel _rentalCar() {
  return TransportViewModel.newRentalCar(
    vehicleModelName: 'Onix',
    vehicleLicensePlate: 'ABC1D23',
    companyName: 'Localiza',
    checkInDate: DateTime(2026, 10, 1),
    checkOutDate: DateTime(2026, 10, 5),
    pickupLocation: 'Aeroporto de Congonhas',
  ) as RentalCarViewModel;
}

void main() {
  testWidgets('pickup location is a places-autocomplete field — the original model had none', (tester) async {
    await tester.pumpWidget(_wrap(RentalCarForm(
      rentalCar: _rentalCar(),
      onChanged: (_) {},
      fetchSuggestions: (query) async => const [],
    )));

    expect(find.text('Pickup location'), findsOneWidget);
    expect(find.text('Aeroporto de Congonhas'), findsOneWidget);
  });

  testWidgets('selecting a pickup location suggestion emits its coordinate', (tester) async {
    RentalCarViewModel? emitted;

    await tester.pumpWidget(_wrap(RentalCarForm(
      rentalCar: _rentalCar(),
      onChanged: (v) => emitted = v,
      fetchSuggestions: (query) async => const [
        PlaceSuggestion(text: 'Aeroporto de Congonhas, SP', coordinate: PlaceCoordinate(-23.62, -46.65)),
      ],
    )));

    // Order: vehicleModelName(0), licensePlate(1), companyName(2), pickupLocation(3).
    final pickupField = find.byType(TextField).at(3);
    await tester.enterText(pickupField, 'Congonhas');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aeroporto de Congonhas'));
    await tester.pump();

    expect(emitted, isNotNull);
    expect(emitted!.pickupLocation, 'Aeroporto de Congonhas, SP');
    expect(emitted!.pickupLocationCoordinate, const PlaceCoordinate(-23.62, -46.65));
  });

  testWidgets('empty pickup location blocks emission (required field)', (tester) async {
    RentalCarViewModel? emitted;

    await tester.pumpWidget(_wrap(RentalCarForm(
      rentalCar: _rentalCar(),
      onChanged: (v) => emitted = v,
      fetchSuggestions: (query) async => const [],
    )));

    final pickupField = find.byType(TextField).at(3);
    await tester.enterText(pickupField, '');
    await tester.pump();

    expect(emitted, isNull);
    expect(find.text('Pickup location is required'), findsOneWidget);
  });
}
