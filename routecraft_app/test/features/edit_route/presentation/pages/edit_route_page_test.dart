import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/edit_route/presentation/controllers/edit_route_controller.dart';
import 'package:routecraft_app/features/edit_route/presentation/pages/edit_route_page.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/route_repository.dart';
import 'package:routecraft_app/features/travels/domain/usecases/route_usecases.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

class _FakeRouteRepository implements RouteRepository {
  Result<RoutePlan>? nextUpdateResult;

  @override
  Future<Result<RoutePlan>> updateRoute(String travelId, RoutePlan routePlan) async => nextUpdateResult!;
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
      participantsList: const [],
      routePlan: _originalRoute(),
    );

Widget _wrap(Travel travel, {RouteRepository? repository}) {
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
        routeUseCases: RouteUseCases(repository ?? _FakeRouteRepository()),
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
