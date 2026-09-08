import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/edit_route/presentation/controllers/edit_route_controller.dart';
import 'package:routecraft_app/features/edit_route/presentation/pages/edit_route_page.dart';
import 'package:routecraft_app/features/travels/domain/entities/person.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/participants_repository.dart';
import 'package:routecraft_app/features/travels/domain/repositories/route_repository.dart';
import 'package:routecraft_app/features/travels/domain/usecases/participants_usecases.dart';
import 'package:routecraft_app/features/travels/domain/usecases/route_usecases.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

class _FakeRouteRepository implements RouteRepository {
  Result<RoutePlan>? nextUpdateResult;

  @override
  Future<Result<RoutePlan>> updateRoute(String travelId, RoutePlan routePlan) async => nextUpdateResult!;
}

class _FakeParticipantsRepository implements ParticipantsRepository {
  @override
  Future<Result<List<Person>>> updateParticipants(String travelId, List<Person> participants) async =>
      Result.success(participants);
}

RoutePlan _originalRoute() => RoutePlan(
      domainId: 'r1',
      backEndId: 'r1',
      startDate: DateTime(2026, 10, 12),
      endDate: DateTime(2026, 10, 19),
      startLocation: 'São Paulo',
      destination: 'Paraty',
      interestsList: [
        InterestPoint(domainId: 'i1', backEndId: 'i1', name: 'Trilha do Sono', description: ''),
      ],
    );

Travel _travel(TravelStatus status) => Travel(
      domainId: 't1',
      backEndId: 't1',
      clientName: 'Rafaela Souza',
      travelName: 'Litoral Norte',
      travelStatus: status,
      participantsList: [Person(domainId: 'p1', backEndId: 'p1', name: 'Rafaela Souza', age: '30', sex: 'F')],
      routePlan: _originalRoute(),
    );

Widget _wrap(Travel travel, {RouteRepository? repository, ParticipantsRepository? participantsRepository}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: EditRoutePage(
      travel: travel,
      controller: EditRouteController(
        travelId: travel.backEndId!,
        original: travel.routePlan,
        showPublishedWarning: travel.hasItinerary,
        clientName: travel.clientName,
        originalParticipants: travel.participantsList,
        routeUseCases: RouteUseCases(repository ?? _FakeRouteRepository()),
        participantsUseCases: ParticipantsUseCases(participantsRepository ?? _FakeParticipantsRepository()),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the published-itinerary warning only when the trip already has one', (tester) async {
    await tester.pumpWidget(_wrap(_travel(TravelStatus.itineraryCreated)));
    expect(find.textContaining('itinerary has already been built'), findsOneWidget);
  });

  testWidgets('hides the warning when the trip is still route_created', (tester) async {
    await tester.pumpWidget(_wrap(_travel(TravelStatus.routeCreated)));
    expect(find.textContaining('itinerary has already been built'), findsNothing);
  });

  testWidgets('the Save action and the submit button start disabled with no changes', (tester) async {
    await tester.pumpWidget(_wrap(_travel(TravelStatus.routeCreated)));

    final saveButton = tester.widget<TextButton>(find.widgetWithText(TextButton, 'SAVE'));
    expect(saveButton.onPressed, isNull);
    final submitButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Send changes'));
    expect(submitButton.onPressed, isNull);
    expect(find.textContaining('PENDING CHANGE'), findsNothing);
  });

  testWidgets('editing the destination enables submit and shows the pending-changes diff', (tester) async {
    await tester.pumpWidget(_wrap(_travel(TravelStatus.routeCreated)));

    await tester.enterText(find.widgetWithText(TextFormField, 'Destination'), 'Ubatuba');
    await tester.pump();

    expect(find.text('changed'), findsOneWidget);
    expect(find.textContaining('1 PENDING CHANGE'), findsOneWidget);
    expect(find.textContaining('destination Paraty → Ubatuba'), findsOneWidget);
    final submitButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Send changes'));
    expect(submitButton.onPressed, isNotNull);
  });

  testWidgets('removing an interest strikes it through with an undo action, reversible', (tester) async {
    await tester.pumpWidget(_wrap(_travel(TravelStatus.routeCreated)));

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(find.text('undo'), findsOneWidget);
    expect(find.textContaining('1 interest removed'), findsOneWidget);

    await tester.tap(find.text('undo'));
    await tester.pump();

    expect(find.text('undo'), findsNothing);
    expect(find.textContaining('PENDING CHANGE'), findsNothing);
  });

  testWidgets('submitting successfully shows the success screen', (tester) async {
    final repository = _FakeRouteRepository()..nextUpdateResult = Result.success(_originalRoute());
    await tester.pumpWidget(_wrap(_travel(TravelStatus.routeCreated), repository: repository));

    await tester.enterText(find.widgetWithText(TextFormField, 'Destination'), 'Ubatuba');
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Send changes'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Send changes'));
    await tester.pumpAndSettle();

    expect(find.text('Route updated successfully!'), findsOneWidget);
  });

  testWidgets('the client participant has no remove button, shown as "You" instead', (tester) async {
    await tester.pumpWidget(_wrap(_travel(TravelStatus.routeCreated)));

    expect(find.text('Rafaela Souza'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('marking a non-client participant for removal strikes it through with an undo action', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final travel = _travel(TravelStatus.routeCreated);
    final travelWithChild = Travel(
      domainId: travel.domainId,
      backEndId: travel.backEndId,
      clientName: travel.clientName,
      travelName: travel.travelName,
      travelStatus: travel.travelStatus,
      participantsList: [
        ...travel.participantsList,
        Person(domainId: 'p2', backEndId: 'p2', name: 'João', age: '10', sex: 'M'),
      ],
      routePlan: travel.routePlan,
    );
    final controller = EditRouteController(
      travelId: travelWithChild.backEndId!,
      original: travelWithChild.routePlan,
      showPublishedWarning: travelWithChild.hasItinerary,
      clientName: travelWithChild.clientName,
      originalParticipants: travelWithChild.participantsList,
      routeUseCases: RouteUseCases(_FakeRouteRepository()),
      participantsUseCases: ParticipantsUseCases(_FakeParticipantsRepository()),
    );

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: EditRoutePage(travel: travelWithChild, controller: controller),
    ));

    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    expect(find.text('João'), findsOneWidget);
    expect(find.textContaining('1 participant removed'), findsOneWidget);

    await tester.tap(find.text('undo').last);
    await tester.pump();

    expect(find.textContaining('participant removed'), findsNothing);
  });

  testWidgets('a failed submission surfaces the error message and stays on the form', (tester) async {
    final repository = _FakeRouteRepository()..nextUpdateResult = const Result.failure('Erro de rede');
    await tester.pumpWidget(_wrap(_travel(TravelStatus.routeCreated), repository: repository));

    await tester.enterText(find.widgetWithText(TextFormField, 'Destination'), 'Ubatuba');
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Send changes'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Send changes'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to update route'), findsOneWidget);
    expect(find.text('Route updated successfully!'), findsNothing);
  });
}
