import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/app/global_controllers/travel_sync_status_controller.dart';
import 'package:routecraft_app/features/itinerary_hub/presentation/pages/itinerary_hub_page.dart';
import 'package:routecraft_app/features/travels/domain/entities/itinerary.dart';
import 'package:routecraft_app/features/travels/domain/entities/itinerary_step.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/transport.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

Widget _wrap(Widget child, {TravelSyncStatusController? syncStatus}) {
  return ChangeNotifierProvider.value(
    value: syncStatus ?? TravelSyncStatusController(),
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

RoutePlan _routePlan() => RoutePlan(
      domainId: 'r1',
      backEndId: 'r1',
      startDate: DateTime(2026, 10, 12),
      endDate: DateTime(2026, 10, 19),
      startLocation: 'São Paulo',
      destination: 'Paraty',
      interestsList: [
        InterestPoint(domainId: 'i1', backEndId: null, name: 'Trilha', description: ''),
      ],
    );

Travel _travel(TravelStatus status, {Itinerary? itinerary}) => Travel(
      domainId: 't1',
      backEndId: 't1',
      clientName: 'Rafaela Souza',
      travelName: 'Litoral Norte',
      travelStatus: status,
      participantsList: const [],
      routePlan: _routePlan(),
      itinerary: itinerary,
    );

void main() {
  group('nextUpcomingStep', () {
    test('returns null when there are no steps', () {
      expect(nextUpcomingStep(const []), isNull);
    });

    test('returns null when every step is finished', () {
      final step = ItineraryStep.newStop(
        domainId: 's1',
        backEndId: null,
        title: 'Done',
        startDate: DateTime(2020, 1, 1),
        finishDate: DateTime(2020, 1, 2),
        finished: true,
        name: 'Stop',
        description: '',
        experiences: const [],
      );

      expect(nextUpcomingStep([step]), isNull);
    });

    test('picks the earliest unfinished step, ignoring order in the list', () {
      final later = ItineraryStep.newStop(
        domainId: 's1',
        backEndId: null,
        title: 'Later',
        startDate: DateTime(2026, 3, 1),
        finishDate: DateTime(2026, 3, 2),
        finished: false,
        name: 'Later',
        description: '',
        experiences: const [],
      );
      final sooner = ItineraryStep.newStop(
        domainId: 's2',
        backEndId: null,
        title: 'Sooner',
        startDate: DateTime(2026, 1, 1),
        finishDate: DateTime(2026, 1, 2),
        finished: false,
        name: 'Sooner',
        description: '',
        experiences: const [],
      );

      expect(nextUpcomingStep([later, sooner])?.title, 'Sooner');
    });
  });

  testWidgets('shows an empty state pointing to Home when no trip is selected', (tester) async {
    await tester.pumpWidget(_wrap(const ItineraryHubPage(travel: null)));

    expect(find.text('No trip selected'), findsOneWidget);
    expect(find.text('Go to Home'), findsOneWidget);
  });

  testWidgets('shows the offline banner when the sync status controller reports offline', (tester) async {
    final syncStatus = TravelSyncStatusController()..update(isOffline: true, syncedAt: DateTime(2026, 10, 13));

    await tester.pumpWidget(_wrap(ItineraryHubPage(travel: _travel(TravelStatus.routeCreated)), syncStatus: syncStatus));

    expect(find.text('Offline · data from 13 Oct 2026'), findsOneWidget);
  });

  testWidgets('shows no offline banner when the sync status controller reports online', (tester) async {
    await tester.pumpWidget(_wrap(ItineraryHubPage(travel: _travel(TravelStatus.routeCreated))));

    expect(find.textContaining('Offline ·'), findsNothing);
  });

  group('route_created state', () {
    testWidgets('shows the awaiting-agent message and the route summary, without any edit-itinerary affordance', (tester) async {
      await tester.pumpWidget(_wrap(ItineraryHubPage(travel: _travel(TravelStatus.routeCreated))));

      expect(find.text('Litoral Norte'), findsOneWidget);
      expect(find.text('Your agent is preparing your itinerary'), findsOneWidget);
      expect(find.text('São Paulo → Paraty'), findsOneWidget);
      expect(find.textContaining('1 interest'), findsOneWidget);

      // No itinerary yet — the client never gets a create/edit-steps action.
      expect(find.text('Open full itinerary'), findsNothing);
      expect(find.text('NEXT STEP', skipOffstage: false), findsNothing);
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('the "edit route" link is present but only the route, no itinerary editing', (tester) async {
      await tester.pumpWidget(_wrap(ItineraryHubPage(travel: _travel(TravelStatus.routeCreated))));

      expect(find.text('edit route'), findsOneWidget);
    });
  });

  group('itinerary_created state', () {
    testWidgets('shows the next upcoming step, counters and the route summary', (tester) async {
      final itinerary = Itinerary(
        domainId: 'it1',
        backEndId: 'it1',
        agentName: 'Ana',
        itinerarySteps: [
          ItineraryStep.newStop(
            domainId: 's1',
            backEndId: 's1',
            title: 'Finished stop',
            startDate: DateTime(2020, 1, 1),
            finishDate: DateTime(2020, 1, 2),
            finished: true,
            name: 'Old stop',
            description: '',
            experiences: const [],
          ),
          ItineraryStep.newTravelSegment(
            domainId: 's2',
            backEndId: 's2',
            title: 'Flight GRU → SDU',
            startDate: DateTime(2020, 6, 1),
            finishDate: DateTime(2020, 6, 1, 10),
            finished: false,
            startPoint: 'GRU',
            finishPoint: 'SDU',
            transport: Transport.newAirplane(
              domainId: 'tr1',
              backEndId: 'tr1',
              flightNumber: 'LA3421',
              flightCompany: 'LATAM',
              flightDate: DateTime(2020, 6, 1),
              departureGate: 'A1',
              departureAirport: 'GRU',
              arrivalAirport: 'SDU',
            ),
          ),
        ],
      );

      await tester.pumpWidget(_wrap(
        ItineraryHubPage(travel: _travel(TravelStatus.itineraryCreated, itinerary: itinerary)),
      ));

      // The finished step is skipped — the unfinished one is "next".
      expect(find.text('Flight GRU → SDU'), findsOneWidget);
      expect(find.text('Finished stop'), findsNothing);
      expect(find.text('2'), findsOneWidget); // STEPS counter
      expect(find.text('7'), findsOneWidget); // NIGHTS counter
      expect(find.text('Open full itinerary'), findsOneWidget);
    });

    testWidgets('hides the next-step card when every step is already finished', (tester) async {
      final itinerary = Itinerary(
        domainId: 'it1',
        backEndId: 'it1',
        agentName: 'Ana',
        itinerarySteps: [
          ItineraryStep.newStop(
            domainId: 's1',
            backEndId: 's1',
            title: 'Done',
            startDate: DateTime(2020, 1, 1),
            finishDate: DateTime(2020, 1, 2),
            finished: true,
            name: 'Old stop',
            description: '',
            experiences: const [],
          ),
        ],
      );

      await tester.pumpWidget(_wrap(
        ItineraryHubPage(travel: _travel(TravelStatus.itineraryCreated, itinerary: itinerary)),
      ));

      expect(find.textContaining('NEXT STEP'), findsNothing);
    });

    testWidgets('counts the next step as "in 1 day" by calendar date, not by a raw 24h duration', (tester) async {
      // Regardless of what time "now" is when this test runs, tomorrow's
      // calendar date is always exactly 1 day away — this pins the
      // calendar-day comparison, not a flaky Duration.inDays truncation.
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final itinerary = Itinerary(
        domainId: 'it1',
        backEndId: 'it1',
        agentName: 'Ana',
        itinerarySteps: [
          ItineraryStep.newStop(
            domainId: 's1',
            backEndId: 's1',
            title: 'Tomorrow stop',
            startDate: tomorrow,
            finishDate: tomorrow,
            finished: false,
            name: 'Stop',
            description: '',
            experiences: const [],
          ),
        ],
      );

      await tester.pumpWidget(_wrap(
        ItineraryHubPage(travel: _travel(TravelStatus.itineraryCreated, itinerary: itinerary)),
      ));

      expect(find.textContaining('in 1 day'), findsOneWidget);
    });
  });
}
