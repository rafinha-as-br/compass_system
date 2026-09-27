import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/models/place_suggestion.dart';
import 'package:routecraft_app/shared/widgets/places_autocomplete_field.dart';

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

const _debounce = Duration(milliseconds: 400);

void main() {
  testWidgets('debounce: continuous typing fires exactly one fetch, for the final text', (tester) async {
    var callCount = 0;
    String? lastQuery;

    await tester.pumpWidget(_wrap(PlacesAutocompleteField(
      labelText: 'Origem',
      debounceDuration: _debounce,
      fetchSuggestions: (query) async {
        callCount++;
        lastQuery = query;
        return const [];
      },
      onChanged: (_) {},
    )));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'flo');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'flor');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'flori');
    // Not enough time has elapsed since the last keystroke — no fetch yet.
    expect(callCount, 0);

    await tester.pump(_debounce);

    expect(callCount, 1);
    expect(lastQuery, 'flori');
  });

  testWidgets('loading state shows skeleton rows while the fetch is in flight', (tester) async {
    final completer = Completer<List<PlaceSuggestion>>();

    await tester.pumpWidget(_wrap(PlacesAutocompleteField(
      labelText: 'Origem',
      debounceDuration: _debounce,
      fetchSuggestions: (query) => completer.future,
      onChanged: (_) {},
    )));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'flor');
    await tester.pump(_debounce);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const [PlaceSuggestion(text: 'Florianópolis', coordinate: PlaceCoordinate(-27.5, -48.5))]);
    await tester.pumpAndSettle();

    expect(find.text('Florianópolis'), findsOneWidget);
  });

  testWidgets('empty state shows the no-results message', (tester) async {
    await tester.pumpWidget(_wrap(PlacesAutocompleteField(
      labelText: 'Origem',
      debounceDuration: _debounce,
      fetchSuggestions: (query) async => const [],
      onChanged: (_) {},
    )));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump(_debounce);
    await tester.pumpAndSettle();

    expect(find.text('Nenhum lugar encontrado'), findsOneWidget);
  });

  testWidgets('error state degrades to free text instead of blocking the field', (tester) async {
    await tester.pumpWidget(_wrap(PlacesAutocompleteField(
      labelText: 'Origem',
      debounceDuration: _debounce,
      fetchSuggestions: (query) async => throw Exception('Nominatim indisponível'),
      onChanged: (_) {},
    )));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'flor');
    await tester.pump(_debounce);
    await tester.pumpAndSettle();

    expect(find.text('Busca indisponível — texto livre aceito'), findsOneWidget);
    // The dropdown itself is gone (degraded), but the field is still enabled.
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled ?? true, isTrue);
    await tester.enterText(find.byType(TextField), 'floripa sem sugestao');
    expect(find.text('floripa sem sugestao'), findsOneWidget);
  });

  testWidgets('selecting a suggestion fills the field and reports its coordinate', (tester) async {
    final reported = <PlaceAutocompleteResult>[];

    await tester.pumpWidget(_wrap(PlacesAutocompleteField(
      labelText: 'Origem',
      debounceDuration: _debounce,
      fetchSuggestions: (query) async => const [
        PlaceSuggestion(text: 'Florianópolis, SC, Brasil', coordinate: PlaceCoordinate(-27.5954, -48.5480)),
      ],
      onChanged: reported.add,
    )));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'flor');
    await tester.pump(_debounce);
    await tester.pumpAndSettle();

    // The row splits the suggestion into title/subtitle at the first comma
    // (see _buildSuggestionRow) — tap the title fragment.
    await tester.tap(find.text('Florianópolis'));
    await tester.pump();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller!.text, 'Florianópolis, SC, Brasil');

    final last = reported.last;
    expect(last.text, 'Florianópolis, SC, Brasil');
    expect(last.coordinate, const PlaceCoordinate(-27.5954, -48.5480));

    // Typing again invalidates the previous selection (coordinate resets).
    await tester.enterText(find.byType(TextField), 'Florianópolis, SC, Brasil!');
    expect(reported.last.coordinate, isNull);
  });

  testWidgets('a query shorter than 2 chars never triggers a fetch', (tester) async {
    var called = false;

    await tester.pumpWidget(_wrap(PlacesAutocompleteField(
      labelText: 'Origem',
      debounceDuration: _debounce,
      fetchSuggestions: (query) async {
        called = true;
        return const [];
      },
      onChanged: (_) {},
    )));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'f');
    await tester.pump(_debounce);

    expect(called, isFalse);
  });

  testWidgets('error notice does not overflow in a narrow column (e.g. a two-field form row)', (tester) async {
    await tester.pumpWidget(_wrap(SizedBox(
      width: 150,
      child: PlacesAutocompleteField(
        labelText: 'Origem',
        debounceDuration: _debounce,
        fetchSuggestions: (query) async => throw Exception('Nominatim indisponível'),
        onChanged: (_) {},
      ),
    )));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'flor');
    await tester.pump(_debounce);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
