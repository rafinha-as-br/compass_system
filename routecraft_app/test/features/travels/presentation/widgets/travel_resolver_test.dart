import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/presentation/widgets/travel_resolver.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

Travel _travel(String name) => Travel(
      domainId: name,
      backEndId: name,
      clientName: 'Maria Silva',
      travelName: name,
      travelStatus: TravelStatus.routeCreated,
      participantsList: const [],
      routePlan: RoutePlan(
        domainId: '$name-route',
        backEndId: null,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 5),
        startLocation: 'SP',
        destination: 'Lisbon',
        interestsList: const [],
      ),
    );

void main() {
  group('TravelResolver', () {
    testWidgets('calls the builder immediately when the travel is already available', (tester) async {
      await tester.pumpWidget(_wrap(TravelResolver(
        travel: _travel('Chapada'),
        travelId: null,
        builder: (context, travel) => Text(travel.travelName),
      )));

      expect(find.text('Chapada'), findsOneWidget);
    });

    testWidgets('shows a treated error state — no CTA retry — when neither travel nor id is available',
        (tester) async {
      await tester.pumpWidget(_wrap(TravelResolver(
        travel: null,
        travelId: null,
        builder: (context, travel) => Text(travel.travelName),
      )));

      expect(find.text('Trip not found'), findsOneWidget);
      expect(find.text('Go to Home'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });
  });
}
