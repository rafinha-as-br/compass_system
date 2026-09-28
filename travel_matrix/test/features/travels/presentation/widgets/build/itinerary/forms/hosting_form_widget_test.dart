import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/itinerary_steps_view_models.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/forms/hosting_form_widget.dart';
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
      home: Scaffold(body: child),
    );

HostingStepViewModel _hosting({String address = 'Hotel Central', PlaceCoordinate? coordinate}) {
  return ItineraryStepViewModel.newHosting(
    title: 'Hospedagem',
    startDate: DateTime(2026, 10, 1),
    finishDate: DateTime(2026, 10, 5),
    position: StepPosition.middle,
    placeName: 'Hotel Central',
    address: address,
    checkIn: DateTime(2026, 10, 1),
    checkOut: DateTime(2026, 10, 5),
    coordinate: coordinate,
  ) as HostingStepViewModel;
}

void main() {
  testWidgets('selecting an address suggestion emits the hosting with the picked coordinate', (tester) async {
    HostingStepViewModel? emitted;

    await tester.pumpWidget(_wrap(HostingFormWidget(
      hosting: _hosting(),
      onChanged: (h) => emitted = h,
      onDelete: () {},
      fetchSuggestions: (query) async => const [
        PlaceSuggestion(text: 'Rua das Flores, 100', coordinate: PlaceCoordinate(-23.5, -46.6)),
      ],
    )));

    // Address is the second TextField (name is the first) — both render as
    // plain TextField via PlacesAutocompleteField/AppTextField internals,
    // but only the address one is a PlacesAutocompleteField here.
    final addressField = find.byType(TextField).at(1);
    await tester.tap(addressField);
    await tester.enterText(addressField, 'Rua');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // PlacesAutocompleteField splits the suggestion at the first comma into
    // title/subtitle — tap the title fragment.
    await tester.tap(find.text('Rua das Flores'));
    await tester.pump();

    expect(emitted, isNotNull);
    expect(emitted!.address, 'Rua das Flores, 100');
    expect(emitted!.coordinate, const PlaceCoordinate(-23.5, -46.6));
  });

  testWidgets('typing free text after a selection clears the coordinate', (tester) async {
    HostingStepViewModel? emitted;

    await tester.pumpWidget(_wrap(HostingFormWidget(
      hosting: _hosting(coordinate: const PlaceCoordinate(-23.5, -46.6)),
      onChanged: (h) => emitted = h,
      onDelete: () {},
      fetchSuggestions: (query) async => const [],
    )));

    final addressField = find.byType(TextField).at(1);
    await tester.enterText(addressField, 'Novo endereço digitado à mão');
    await tester.pump();

    expect(emitted, isNotNull);
    expect(emitted!.coordinate, isNull);
  });

  testWidgets('clearing the address shows a required-field error, like every other required field', (tester) async {
    await tester.pumpWidget(_wrap(HostingFormWidget(
      hosting: _hosting(),
      onChanged: (_) {},
      onDelete: () {},
      fetchSuggestions: (query) async => const [],
    )));

    final addressField = find.byType(TextField).at(1);
    await tester.enterText(addressField, '');
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.fieldRequiredError), findsOneWidget);
  });
}
