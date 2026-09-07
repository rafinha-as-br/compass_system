import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/app/global_controllers/travel_sync_status_controller.dart';
import 'package:routecraft_app/features/itinerary_timeline/presentation/pages/itinerary_timeline_page.dart';
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

ItineraryStep _stop(String id, DateTime start, DateTime finish, {String title = 'Stop'}) => ItineraryStep.newStop(
      domainId: id,
      backEndId: id,
      title: title,
      startDate: start,
      finishDate: finish,
      finished: false,
      name: title,
      description: '',
      experiences: const [],
    );

Travel _travel({required RoutePlan routePlan, Itinerary? itinerary}) => Travel(
      domainId: 't1',
      backEndId: 't1',
      clientName: 'Rafaela Souza',
      travelName: 'Litoral Norte',
      travelStatus: TravelStatus.itineraryCreated,
      participantsList: const [],
      routePlan: routePlan,
      itinerary: itinerary,
    );

RoutePlan _routePlan(DateTime start, DateTime end) => RoutePlan(
      domainId: 'r1',
      backEndId: 'r1',
      startDate: start,
      endDate: end,
      startLocation: 'São Paulo',
      destination: 'Paraty',
      interestsList: const [],
    );

void main() {
  group('buildDayItineraries', () {
    test('buckets a 3-day trip into 3 days, each holding the steps that touch it', () {
      final days = buildDayItineraries(
        tripStart: DateTime(2026, 10, 12),
        tripEnd: DateTime(2026, 10, 14),
        steps: [
          _stop('s1', DateTime(2026, 10, 12, 8), DateTime(2026, 10, 12, 9), title: 'Day 1 stop'),
          _stop('s2', DateTime(2026, 10, 14, 8), DateTime(2026, 10, 14, 9), title: 'Day 3 stop'),
        ],
      );

      expect(days, hasLength(3));
      expect(days[0].dayNumber, 1);
      expect(days[0].steps.map((s) => s.title), ['Day 1 stop']);
      expect(days[1].steps, isEmpty);
      expect(days[2].steps.map((s) => s.title), ['Day 3 stop']);
    });

    test('a multi-day step appears on every day it spans, not just the day it starts', () {
      final hosting = ItineraryStep.newHosting(
        domainId: 'h1',
        backEndId: 'h1',
        title: 'Pousada',
        startDate: DateTime(2026, 10, 12, 16),
        finishDate: DateTime(2026, 10, 14, 11),
        finished: false,
        name: 'Pousada Vila do Porto',
        address: 'Rua X',
        checkIn: DateTime(2026, 10, 12, 16),
        checkOut: DateTime(2026, 10, 14, 11),
      );

      final days = buildDayItineraries(
        tripStart: DateTime(2026, 10, 12),
        tripEnd: DateTime(2026, 10, 14),
        steps: [hosting],
      );

      expect(days[0].steps, contains(hosting));
      expect(days[1].steps, contains(hosting));
      expect(days[2].steps, contains(hosting));
    });

    test('the trailing free-time gap points to the next step even when it is tomorrow', () {
      final days = buildDayItineraries(
        tripStart: DateTime(2026, 10, 12),
        tripEnd: DateTime(2026, 10, 13),
        steps: [
          _stop('s1', DateTime(2026, 10, 12, 7), DateTime(2026, 10, 12, 16)),
          _stop('s2', DateTime(2026, 10, 13, 9), DateTime(2026, 10, 13, 10)),
        ],
      );

      expect(days[0].freeTimeUntil, DateTime(2026, 10, 13, 9));
      // Last day of the itinerary: nothing scheduled after its last step.
      expect(days[1].freeTimeUntil, isNull);
    });

    test('a multi-day step spanning the whole trip does not suppress the free-time gap', () {
      // Regression: a Hosting step's finishDate (checkout, days away) used to
      // always "win" as the day's last step, so no later candidate's
      // startDate was ever after it — free time never showed up on any day.
      final hosting = ItineraryStep.newHosting(
        domainId: 'h1',
        backEndId: 'h1',
        title: 'Pousada',
        startDate: DateTime(2026, 10, 12, 16),
        finishDate: DateTime(2026, 10, 15, 11),
        finished: false,
        name: 'Pousada Vila do Porto',
        address: 'Rua X',
        checkIn: DateTime(2026, 10, 12, 16),
        checkOut: DateTime(2026, 10, 15, 11),
      );
      final sightseeing = _stop('s2', DateTime(2026, 10, 14, 10), DateTime(2026, 10, 14, 12), title: 'Passeio');

      final days = buildDayItineraries(
        tripStart: DateTime(2026, 10, 12),
        tripEnd: DateTime(2026, 10, 15),
        steps: [hosting, sightseeing],
      );

      // Day 1 (hosting checks in at 16:00, nothing else known until the
      // sightseeing on day 3) and day 2 (hosting only) both point ahead to it.
      expect(days[0].freeTimeUntil, DateTime(2026, 10, 14, 10));
      expect(days[1].freeTimeUntil, DateTime(2026, 10, 14, 10));
      // Day 3 (sightseeing) and day 4 (checkout): nothing is scheduled after
      // either one, so — like the last day of any itinerary — no gap shows.
      expect(days[2].freeTimeUntil, isNull);
      expect(days[3].freeTimeUntil, isNull);
    });

    test('no free-time gap when steps run back-to-back', () {
      final days = buildDayItineraries(
        tripStart: DateTime(2026, 10, 12),
        tripEnd: DateTime(2026, 10, 12),
        steps: [
          _stop('s1', DateTime(2026, 10, 12, 7), DateTime(2026, 10, 12, 9)),
          _stop('s2', DateTime(2026, 10, 12, 9), DateTime(2026, 10, 12, 10)),
        ],
      );

      expect(days[0].freeTimeUntil, isNull);
    });

    test('an empty trip (no steps) still produces one bucket per day, all empty', () {
      final days = buildDayItineraries(
        tripStart: DateTime(2026, 10, 12),
        tripEnd: DateTime(2026, 10, 13),
        steps: const [],
      );

      expect(days, hasLength(2));
      expect(days.every((d) => d.steps.isEmpty), isTrue);
      expect(days.every((d) => d.freeTimeUntil == null), isTrue);
    });

    test('a single-day trip produces exactly one day', () {
      final days = buildDayItineraries(
        tripStart: DateTime(2026, 10, 12),
        tripEnd: DateTime(2026, 10, 12),
        steps: const [],
      );

      expect(days, hasLength(1));
      expect(days.single.dayNumber, 1);
    });
  });

  group('ItineraryTimelinePage', () {
    testWidgets('shows an empty state when there is no trip', (tester) async {
      await tester.pumpWidget(_wrap(const ItineraryTimelinePage(travel: null)));

      expect(find.text('No trip selected'), findsOneWidget);
    });

    testWidgets('shows an empty state when the trip has no itinerary yet', (tester) async {
      await tester.pumpWidget(_wrap(ItineraryTimelinePage(
        travel: _travel(routePlan: _routePlan(DateTime(2026, 10, 12), DateTime(2026, 10, 13))),
      )));

      expect(find.text('No trip selected'), findsOneWidget);
    });

    testWidgets('shows the offline banner when the sync status controller reports offline', (tester) async {
      final syncStatus = TravelSyncStatusController()..update(isOffline: true, syncedAt: DateTime(2026, 10, 13));
      final itinerary = Itinerary(domainId: 'it1', backEndId: 'it1', agentName: 'Ana', itinerarySteps: const []);

      await tester.pumpWidget(_wrap(
        ItineraryTimelinePage(
          travel: _travel(routePlan: _routePlan(DateTime(2026, 10, 12), DateTime(2026, 10, 13)), itinerary: itinerary),
        ),
        syncStatus: syncStatus,
      ));

      expect(find.text('Offline · data from 13 Oct 2026'), findsOneWidget);
    });

    testWidgets('renders day 1 by default with its steps, and an empty day explicitly', (tester) async {
      final itinerary = Itinerary(
        domainId: 'it1',
        backEndId: 'it1',
        agentName: 'Ana',
        itinerarySteps: [
          _stop('s1', DateTime(2026, 10, 12, 7, 40), DateTime(2026, 10, 12, 8, 45), title: 'Voo GRU → SDU'),
        ],
      );

      await tester.pumpWidget(_wrap(ItineraryTimelinePage(
        travel: _travel(
          routePlan: _routePlan(DateTime(2026, 10, 12), DateTime(2026, 10, 13)),
          itinerary: itinerary,
        ),
      )));

      expect(find.text('Litoral Norte'), findsOneWidget);
      expect(find.text('Voo GRU → SDU'), findsOneWidget);
      expect(find.text('07:40'), findsOneWidget);
      expect(find.text('D1'), findsOneWidget);
      expect(find.text('D2'), findsOneWidget);
      expect(find.text('1 step'), findsOneWidget);

      await tester.tap(find.text('D2'));
      await tester.pumpAndSettle();

      expect(find.text('No steps this day'), findsOneWidget);
      expect(find.text('Voo GRU → SDU'), findsNothing);
    });

    testWidgets('Next day/Previous day buttons move between days and respect the trip bounds', (tester) async {
      final itinerary = Itinerary(
        domainId: 'it1',
        backEndId: 'it1',
        agentName: 'Ana',
        itinerarySteps: const [],
      );

      await tester.pumpWidget(_wrap(ItineraryTimelinePage(
        travel: _travel(
          routePlan: _routePlan(DateTime(2026, 10, 12), DateTime(2026, 10, 13)),
          itinerary: itinerary,
        ),
      )));

      expect(find.text('Day 1 · Monday'), findsOneWidget);
      // Day 1 is the first day — "Previous day" is disabled.
      final previousButton = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Previous day'));
      expect(previousButton.onPressed, isNull);

      await tester.tap(find.text('Next day'));
      await tester.pumpAndSettle();

      expect(find.text('Day 2 · Tuesday'), findsOneWidget);
      final nextButton = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Next day'));
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('shows the free-time block and the flight duration/number for a travel segment', (tester) async {
      final itinerary = Itinerary(
        domainId: 'it1',
        backEndId: 'it1',
        agentName: 'Ana',
        itinerarySteps: [
          ItineraryStep.newTravelSegment(
            domainId: 's1',
            backEndId: 's1',
            title: 'Voo GRU → SDU',
            startDate: DateTime(2026, 10, 12, 7, 40),
            finishDate: DateTime(2026, 10, 12, 8, 45),
            finished: false,
            startPoint: 'GRU',
            finishPoint: 'SDU',
            transport: Transport.newAirplane(
              domainId: 'tr1',
              backEndId: 'tr1',
              flightNumber: 'LA3421',
              flightCompany: 'LATAM',
              flightDate: DateTime(2026, 10, 12),
              departureGate: 'A1',
              departureAirport: 'GRU',
              arrivalAirport: 'SDU',
            ),
          ),
          _stop('s2', DateTime(2026, 10, 13, 9), DateTime(2026, 10, 13, 10), title: 'Next-day stop'),
        ],
      );

      await tester.pumpWidget(_wrap(ItineraryTimelinePage(
        travel: _travel(
          routePlan: _routePlan(DateTime(2026, 10, 12), DateTime(2026, 10, 13)),
          itinerary: itinerary,
        ),
      )));

      expect(find.textContaining('1h05'), findsOneWidget);
      expect(find.textContaining('LA3421'), findsOneWidget);
      expect(find.textContaining('Free time'), findsOneWidget);
      expect(find.textContaining('tomorrow'), findsOneWidget);
    });

    testWidgets('tapping a step opens its detail in a bottom sheet', (tester) async {
      final itinerary = Itinerary(
        domainId: 'it1',
        backEndId: 'it1',
        agentName: 'Ana',
        itinerarySteps: [
          _stop('s1', DateTime(2026, 10, 12, 9), DateTime(2026, 10, 12, 10), title: 'Trilha do Sono'),
        ],
      );

      await tester.pumpWidget(_wrap(ItineraryTimelinePage(
        travel: _travel(
          routePlan: _routePlan(DateTime(2026, 10, 12), DateTime(2026, 10, 13)),
          itinerary: itinerary,
        ),
      )));

      await tester.tap(find.text('Trilha do Sono'));
      await tester.pumpAndSettle();

      expect(find.text('Stop'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
    });
  });
}
