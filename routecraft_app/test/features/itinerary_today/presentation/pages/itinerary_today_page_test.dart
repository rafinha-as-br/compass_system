import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/app/global_controllers/travel_sync_status_controller.dart';
import 'package:routecraft_app/features/itinerary_today/presentation/pages/itinerary_today_page.dart';
import 'package:routecraft_app/features/travels/domain/entities/itinerary.dart';
import 'package:routecraft_app/features/travels/domain/entities/itinerary_step.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return ChangeNotifierProvider(
    create: (_) => TravelSyncStatusController(),
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

ItineraryStep _stop(
  String id,
  DateTime start,
  DateTime finish, {
  String title = 'Stop',
  bool finished = false,
}) =>
    ItineraryStep.newStop(
      domainId: id,
      backEndId: id,
      title: title,
      startDate: start,
      finishDate: finish,
      finished: finished,
      name: title,
      description: '',
      experiences: const [],
    );

ItineraryStep _hosting(String id, DateTime checkIn, DateTime checkOut, {String address = 'Rua X, 123'}) =>
    ItineraryStep.newHosting(
      domainId: id,
      backEndId: id,
      title: 'Pousada',
      startDate: checkIn,
      finishDate: checkOut,
      finished: false,
      name: 'Pousada',
      address: address,
      checkIn: checkIn,
      checkOut: checkOut,
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

void main() {
  group('buildTodayItinerary', () {
    final tripStart = DateTime(2026, 10, 12);
    final tripEnd = DateTime(2026, 10, 19);

    test('returns null before the trip starts', () {
      final result = buildTodayItinerary(
        tripStart: tripStart,
        tripEnd: tripEnd,
        steps: const [],
        now: DateTime(2026, 10, 11, 23, 59),
      );

      expect(result, isNull);
    });

    test('returns null after the trip ends', () {
      final result = buildTodayItinerary(
        tripStart: tripStart,
        tripEnd: tripEnd,
        steps: const [],
        now: DateTime(2026, 10, 20),
      );

      expect(result, isNull);
    });

    test('during a step: that step is focused, day/total computed from the trip range', () {
      final steps = [
        _stop('s1', DateTime(2026, 10, 13, 9), DateTime(2026, 10, 13, 13), title: 'Trilha do Sono'),
      ];

      final result = buildTodayItinerary(
        tripStart: tripStart,
        tripEnd: tripEnd,
        steps: steps,
        now: DateTime(2026, 10, 13, 10),
      );

      expect(result, isNotNull);
      expect(result!.dayNumber, 2);
      expect(result.totalDays, 8);
      expect(result.focusedStep?.title, 'Trilha do Sono');
      expect(result.otherStepsToday, isEmpty);
    });

    test('in the gap between two steps: the next one is focused, the earlier finished one is not repeated', () {
      final steps = [
        _stop('s1', DateTime(2026, 10, 13, 7), DateTime(2026, 10, 13, 9), title: 'Check-in', finished: true),
        _stop('s2', DateTime(2026, 10, 13, 14), DateTime(2026, 10, 13, 15), title: 'Volta à pousada'),
      ];

      final result = buildTodayItinerary(
        tripStart: tripStart,
        tripEnd: tripEnd,
        steps: steps,
        now: DateTime(2026, 10, 13, 10),
      );

      expect(result!.focusedStep?.title, 'Volta à pousada');
      expect(result.otherStepsToday.map((s) => s.title), ['Check-in']);
    });

    test('after every step for today is finished, otherStepsToday still lists them all', () {
      final steps = [
        _stop('s1', DateTime(2026, 10, 13, 7), DateTime(2026, 10, 13, 9), title: 'Check-in', finished: true),
      ];

      final result = buildTodayItinerary(
        tripStart: tripStart,
        tripEnd: tripEnd,
        steps: steps,
        now: DateTime(2026, 10, 13, 20),
      );

      expect(result!.otherStepsToday.map((s) => s.title), ['Check-in']);
    });
  });

  group('ItineraryTodayPage', () {
    testWidgets('falls back to the hub when there is no trip', (tester) async {
      await tester.pumpWidget(_wrap(const ItineraryTodayPage(travel: null)));

      expect(find.text('No trip selected'), findsOneWidget);
    });

    testWidgets('falls back to the hub when the trip has no itinerary yet', (tester) async {
      await tester.pumpWidget(_wrap(ItineraryTodayPage(
        travel: _travel(routePlan: _routePlan(DateTime(2026, 10, 12), DateTime(2026, 10, 19))),
        now: DateTime(2026, 10, 13),
      )));

      expect(find.text('Litoral Norte'), findsOneWidget); // hub header, not the Today view
      expect(find.text('Trip in progress'), findsNothing);
    });

    testWidgets('falls back to the hub before the trip starts', (tester) async {
      final itinerary = Itinerary(domainId: 'it1', backEndId: 'it1', agentName: 'Ana', itinerarySteps: const []);

      await tester.pumpWidget(_wrap(ItineraryTodayPage(
        travel: _travel(routePlan: _routePlan(DateTime(2026, 10, 12), DateTime(2026, 10, 19)), itinerary: itinerary),
        now: DateTime(2026, 10, 1),
      )));

      expect(find.text('Litoral Norte'), findsOneWidget); // hub header, not the Today view
      expect(find.text('Trip in progress'), findsNothing);
    });

    testWidgets('falls back to the hub after the trip ends', (tester) async {
      final itinerary = Itinerary(domainId: 'it1', backEndId: 'it1', agentName: 'Ana', itinerarySteps: const []);

      await tester.pumpWidget(_wrap(ItineraryTodayPage(
        travel: _travel(routePlan: _routePlan(DateTime(2026, 10, 12), DateTime(2026, 10, 19)), itinerary: itinerary),
        now: DateTime(2026, 10, 20),
      )));

      expect(find.text('Trip in progress'), findsNothing);
    });

    testWidgets('shows day progress, the focused step with a start countdown, and the rest of today', (tester) async {
      final itinerary = Itinerary(
        domainId: 'it1',
        backEndId: 'it1',
        agentName: 'Ana',
        itinerarySteps: [
          _stop('s1', DateTime(2026, 10, 13, 7), DateTime(2026, 10, 13, 9), title: 'Check-in', finished: true),
          _stop('s2', DateTime(2026, 10, 13, 10, 20), DateTime(2026, 10, 13, 13), title: 'Trilha do Sono'),
          _stop('s3', DateTime(2026, 10, 13, 20), DateTime(2026, 10, 13, 22), title: 'Jantar no centro histórico'),
        ],
      );

      await tester.pumpWidget(_wrap(ItineraryTodayPage(
        travel: _travel(routePlan: _routePlan(DateTime(2026, 10, 12), DateTime(2026, 10, 19)), itinerary: itinerary),
        now: DateTime(2026, 10, 13, 9),
      )));

      expect(find.text('Day 2 of 8'), findsOneWidget);
      expect(find.text('Trip in progress'), findsOneWidget);
      expect(find.text('Trilha do Sono'), findsOneWidget);
      expect(find.textContaining('Starts in'), findsOneWidget);
      expect(find.textContaining('1h20'), findsOneWidget);
      expect(find.text('AFTER THAT'), findsOneWidget);
      expect(find.text('Check-in'), findsOneWidget);
      expect(find.text('Jantar no centro histórico'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget); // the finished check-in
    });

    testWidgets('shows "Happening now" instead of a countdown while the focused step is in progress', (tester) async {
      final itinerary = Itinerary(
        domainId: 'it1',
        backEndId: 'it1',
        agentName: 'Ana',
        itinerarySteps: [
          _stop('s1', DateTime(2026, 10, 13, 9), DateTime(2026, 10, 13, 13), title: 'Trilha do Sono'),
        ],
      );

      await tester.pumpWidget(_wrap(ItineraryTodayPage(
        travel: _travel(routePlan: _routePlan(DateTime(2026, 10, 12), DateTime(2026, 10, 19)), itinerary: itinerary),
        now: DateTime(2026, 10, 13, 10),
      )));

      expect(find.text('Happening now'), findsOneWidget);
    });

    testWidgets('shows the address for a Hosting focused step', (tester) async {
      final itinerary = Itinerary(
        domainId: 'it1',
        backEndId: 'it1',
        agentName: 'Ana',
        itinerarySteps: [
          _hosting('h1', DateTime(2026, 10, 13, 16), DateTime(2026, 10, 14, 11), address: 'Rua das Flores, 123'),
        ],
      );

      await tester.pumpWidget(_wrap(ItineraryTodayPage(
        travel: _travel(routePlan: _routePlan(DateTime(2026, 10, 12), DateTime(2026, 10, 19)), itinerary: itinerary),
        now: DateTime(2026, 10, 13, 9),
      )));

      expect(find.textContaining('Rua das Flores, 123'), findsOneWidget);
    });

    testWidgets('tapping "View step" shows the coming-soon stub (CPS-92 not yet wired here)', (tester) async {
      final itinerary = Itinerary(
        domainId: 'it1',
        backEndId: 'it1',
        agentName: 'Ana',
        itinerarySteps: [
          _stop('s1', DateTime(2026, 10, 13, 9), DateTime(2026, 10, 13, 13), title: 'Trilha do Sono'),
        ],
      );

      await tester.pumpWidget(_wrap(ItineraryTodayPage(
        travel: _travel(routePlan: _routePlan(DateTime(2026, 10, 12), DateTime(2026, 10, 19)), itinerary: itinerary),
        now: DateTime(2026, 10, 13, 9),
      )));

      await tester.tap(find.text('View step'));
      await tester.pumpAndSettle();

      expect(find.text('Coming soon.'), findsOneWidget);
    });
  });
}
