import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/pages/views/itinerary_view_tab.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

Travel _travelWithItinerary() => Travel(
  domainId: 't1',
  backEndId: 't1',
  clientName: 'Maria Silva',
  travelName: 'Lisbon 2025',
  travelStatus: TravelStatus.itineraryCreated,
  participantsList: const [],
  routePlan: RoutePlan(
    domainId: 'r1',
    backEndId: 'r1',
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 1, 10),
    startLocation: 'Sao Paulo',
    destination: 'Lisbon',
    interestsList: const [],
  ),
  itinerary: Itinerary(
    domainId: 'i1',
    backEndId: 'i1',
    agentName: 'Carlos Agent',
    itinerarySteps: const [],
  ),
);

void main() {
  testWidgets('does not show its own edit button — editing itinerary lives only in the app bar', (
    tester,
  ) async {
    final travel = TravelViewModel.fromDomain(_travelWithItinerary());

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ItineraryViewTab(travel: travel)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Itinerary'), findsNothing);
    expect(find.byIcon(Icons.edit_calendar), findsNothing);
  });
}
