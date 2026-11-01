import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary_step.dart';
import 'package:travel_matrix/features/travels/domain/entities/person.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/pages/views/overview_view_tab.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/widgets/participant_avatar.dart';

RoutePlan _route() => RoutePlan(
  domainId: 'r1',
  backEndId: 'r1',
  startDate: DateTime(2026, 1, 1),
  endDate: DateTime(2026, 1, 11),
  startLocation: 'Sao Paulo',
  destination: 'Lisbon',
  interestsList: const [],
);

Travel _travel({
  TravelStatus status = TravelStatus.routeCreated,
  bool prepared = false,
  List<Person> participants = const [],
  Itinerary? itinerary,
}) {
  return Travel(
    domainId: 't1',
    backEndId: 't1',
    clientName: 'Maria Silva',
    travelName: 'Lisbon 2026',
    travelStatus: status,
    prepared: prepared,
    participantsList: participants,
    routePlan: _route(),
    itinerary: itinerary,
  );
}

Person _person(String name) => Person(domainId: name, backendId: name, name: name, age: '30', sex: 'F');

Future<void> _pump(WidgetTester tester, Travel travel, {double width = 1200}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final travelViewModel = TravelViewModel.fromDomain(travel);

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(body: OverviewViewTab(travel: travelViewModel)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the route summary with origin, destination and duration in days', (tester) async {
    await _pump(tester, _travel());

    expect(find.text('Sao Paulo'), findsOneWidget);
    expect(find.text('Lisbon'), findsOneWidget);
    expect(find.text('10 days'), findsOneWidget);
  });

  for (final width in [1200.0, 500.0]) {
    testWidgets('route connector is centered on the origin/destination text at width $width', (tester) async {
      await _pump(tester, _travel(), width: width);

      final arrow = find.byIcon(Icons.arrow_forward);
      expect(arrow, findsOneWidget);
      expect(tester.takeException(), isNull);

      final arrowCenter = tester.getCenter(arrow);
      expect(arrowCenter.dy, closeTo(tester.getCenter(find.text('Sao Paulo')).dy, 1));
      expect(arrowCenter.dy, closeTo(tester.getCenter(find.text('Lisbon')).dy, 1));
      // Connector sits between origin and destination.
      expect(arrowCenter.dx, greaterThan(tester.getRect(find.text('Sao Paulo')).right));
      expect(arrowCenter.dx, lessThan(tester.getRect(find.text('Lisbon')).left));
      // Icon matches the 22px value text instead of the old 18px.
      expect(tester.getSize(arrow).height, 22);
    });
  }

  testWidgets('narrow connector takes no more room from the endpoints than the old 18px arrow', (tester) async {
    await _pump(tester, _travel(), width: 500);

    final gap = tester.getRect(find.text('Lisbon')).left - tester.getRect(find.text('Sao Paulo')).right;
    expect(gap, lessThanOrEqualTo(18));
    expect(tester.takeException(), isNull);
  });

  testWidgets('maps each TravelStatus to its localized label and support line', (tester) async {
    await tester.pumpWidget(Container());

    // itineraryCreated only displays as "Ready" once prepared is also true
    // (CPS-166) — travelStatus alone stopped being enough the moment it
    // started auto-advancing as soon as an itinerary exists.
    for (final entry in [
      (TravelStatus.routeCreated, false, 'Not Ready', 'Route created, itinerary pending'),
      (TravelStatus.itineraryCreated, false, 'Not Ready', 'Route created, itinerary pending'),
      (TravelStatus.itineraryCreated, true, 'Ready', 'Itinerary created'),
      (TravelStatus.travelStarted, false, 'In Progress', 'Travel underway'),
      (TravelStatus.travelFinished, false, 'Completed', 'Travel finished'),
    ]) {
      await _pump(tester, _travel(status: entry.$1, prepared: entry.$2));
      expect(find.text(entry.$3), findsOneWidget);
      expect(find.text(entry.$4), findsOneWidget);
    }
  });

  testWidgets('shows the participants count and every participant, with no "and N more" cutoff', (tester) async {
    await _pump(
      tester,
      _travel(
        participants: [
          _person('Ana Silva'),
          _person('Bruno Costa'),
          _person('Carla Souza'),
          _person('Diego Lima'),
          _person('Elis Rocha'),
          _person('Fabio Nunes'),
          _person('Gina Prado'),
        ],
      ),
    );

    expect(find.text('7'), findsOneWidget);
    expect(find.byType(ParticipantAvatar), findsNWidgets(7));
    for (final name in ['Ana Silva', 'Gina Prado']) {
      expect(find.text(name), findsOneWidget);
    }
    expect(find.textContaining('more'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('participants card shows the chosen character, and initials for those without one', (tester) async {
    await _pump(
      tester,
      _travel(
        participants: [
          Person(domainId: 'a', backendId: 'a', name: 'Ana Silva', age: '30', sex: 'F', avatarIndex: 3),
          _person('Bruno Costa'),
          Person(domainId: 'c', backendId: 'c', name: 'Carla Souza', age: '30', sex: 'F', avatarIndex: 99),
        ],
      ),
    );

    final avatars = tester.widgetList<ParticipantAvatar>(find.byType(ParticipantAvatar)).toList();
    expect(avatars.map((a) => a.avatarIndex), [3, null, 99]);
    // Initials only where there is no (known) character: Bruno has none, and
    // index 99 comes from a newer catalog this build does not ship.
    expect(find.text('BC'), findsOneWidget);
    expect(find.text('CS'), findsOneWidget);
    expect(find.text('AS'), findsNothing);
  });

  testWidgets('tapping "View participants" does not throw even without a Participants tab yet', (tester) async {
    await _pump(tester, _travel(participants: [_person('Ana Silva')]));

    await tester.tap(find.text('View participants →'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('"View participants" button keeps horizontal padding between its edges and the label', (tester) async {
    await _pump(tester, _travel(participants: [_person('Ana Silva')]));

    final button = find.widgetWithText(TextButton, 'View participants →');
    final buttonRect = tester.getRect(button);
    final labelRect = tester.getRect(find.descendant(of: button, matching: find.text('View participants →')));

    expect(labelRect.left - buttonRect.left, greaterThanOrEqualTo(12));
    expect(buttonRect.right - labelRect.right, greaterThanOrEqualTo(12));
  });

  testWidgets('shows the itinerary summary and navigates to the Itinerary tab on tap', (tester) async {
    await _pump(
      tester,
      _travel(
        itinerary: Itinerary(
          domainId: 'i1',
          backEndId: 'i1',
          agentName: 'Carlos',
          itinerarySteps: [
            ItineraryStep.newPlaceholder(
              domainId: 's1',
              backEndId: 's1',
              title: 'Step 1',
              description: 'First step',
              startDate: DateTime(2026, 1, 2),
              finishDate: DateTime(2026, 1, 3),
            ),
          ],
        ),
      ),
    );

    expect(find.text('1 steps · by Carlos'), findsOneWidget);

    final tabController = DefaultTabController.of(
      tester.element(find.byType(OverviewViewTab)),
    );
    expect(tabController.index, 0);

    await tester.tap(find.text('View full itinerary'));
    await tester.pumpAndSettle();

    expect(tabController.index, 2);
  });

  testWidgets('shows the empty itinerary state when there is no itinerary yet', (tester) async {
    await _pump(tester, _travel());

    expect(find.text('No itinerary created yet'), findsOneWidget);
    expect(find.text('Create itinerary'), findsOneWidget);
  });

  testWidgets('stacks the cards in a single column on a narrow window', (tester) async {
    await _pump(tester, _travel(), width: 500);

    expect(tester.takeException(), isNull);
    expect(find.text('Sao Paulo'), findsOneWidget);
  });
}
