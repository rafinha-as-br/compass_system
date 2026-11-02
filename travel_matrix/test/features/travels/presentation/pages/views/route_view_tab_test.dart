import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_participants.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_route.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_travel.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/pages/views/route_view_tab.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

Travel _travel() => Travel(
  domainId: 't1',
  backEndId: 't1',
  clientName: 'Maria Silva',
  travelName: 'Lisbon 2025',
  travelStatus: TravelStatus.routeCreated,
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
);

class _MockCrudTravelUseCases extends Mock implements CrudTravelUseCases {}

class _MockCrudRoute extends Mock implements CrudRoute {}

class _MockCrudParticipants extends Mock implements CrudParticipants {}

Travel _travelWithPoints() => Travel(
  domainId: 't1',
  backEndId: 't1',
  clientName: 'Maria Silva',
  travelName: 'Lisbon 2025',
  travelStatus: TravelStatus.routeCreated,
  participantsList: const [],
  routePlan: RoutePlan(
    domainId: 'r1',
    backEndId: 'r1',
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 1, 10),
    startLocation: 'Sao Paulo',
    destination: 'Lisbon',
    interestsList: [
      InterestPoint(domainId: 'a', backEndId: 'a', name: 'Torre de Belém', description: '', observation: 'Chegar cedo'),
      InterestPoint(domainId: 'b', backEndId: 'b', name: 'Alfama', description: ''),
    ],
  ),
);

void main() {
  group('interest point observation (CPS-180)', () {
    late _MockCrudTravelUseCases travelUseCases;
    late _MockCrudRoute routeUseCases;
    late TravelsController controller;

    setUpAll(() {
      registerFallbackValue(
        RoutePlan(
          domainId: 'fallback',
          backEndId: null,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 2),
          startLocation: '',
          destination: '',
          interestsList: const [],
        ),
      );
    });

    setUp(() {
      travelUseCases = _MockCrudTravelUseCases();
      routeUseCases = _MockCrudRoute();
      when(() => travelUseCases.readAll()).thenAnswer((_) async => const Result.success([]));
      controller = TravelsController(
        travelUseCases: travelUseCases,
        routeUseCases: routeUseCases,
        participantsUseCases: _MockCrudParticipants(),
      );
    });

    Future<void> pump(WidgetTester tester, {ValueChanged<TravelViewModel>? onTravelUpdated}) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: RouteViewTab(
                travel: TravelViewModel.fromDomain(_travelWithPoints()),
                onTravelUpdated: onTravelUpdated,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('shows each point observation, or an add action when it has none', (tester) async {
      await pump(tester);

      expect(find.byKey(const Key('interest_observation_view_a')), findsOneWidget);
      expect(find.text('Chegar cedo'), findsOneWidget);
      expect(find.byKey(const Key('interest_observation_add_b')), findsOneWidget);
    });

    testWidgets('editing and saving persists the route and reports the updated travel', (tester) async {
      when(() => routeUseCases.updateRoute(any(), any())).thenAnswer(
        (invocation) async => Result.success(invocation.positionalArguments[1] as RoutePlan),
      );
      TravelViewModel? reported;
      await pump(tester, onTravelUpdated: (travel) => reported = travel);

      await tester.ensureVisible(find.byKey(const Key('interest_observation_add_b')));
      await tester.tap(find.byKey(const Key('interest_observation_add_b')));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('interest_observation_field_b')), 'Subir a pé');
      await tester.ensureVisible(find.byKey(const Key('interest_observation_save_b')));
      await tester.tap(find.byKey(const Key('interest_observation_save_b')));
      await tester.pumpAndSettle();

      final sent = verify(() => routeUseCases.updateRoute('t1', captureAny())).captured.single as RoutePlan;
      expect(sent.interestsList.map((p) => p.observation), ['Chegar cedo', 'Subir a pé']);
      expect(reported!.route.interests.map((p) => p.observation), ['Chegar cedo', 'Subir a pé']);
      expect(find.byKey(const Key('interest_observation_field_b')), findsNothing);
    });

    testWidgets('cancel leaves edit mode without calling the API', (tester) async {
      await pump(tester);

      await tester.tap(find.byKey(const Key('interest_observation_view_a')));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('interest_observation_field_a')), 'Outra coisa');
      await tester.tap(find.byKey(const Key('interest_observation_cancel_a')));
      await tester.pump();

      verifyNever(() => routeUseCases.updateRoute(any(), any()));
      expect(find.text('Chegar cedo'), findsOneWidget);
    });

    testWidgets('a failed save keeps the field open and offers a retry', (tester) async {
      when(() => routeUseCases.updateRoute(any(), any())).thenAnswer((_) async => const Result.failure('boom'));
      await pump(tester);

      await tester.ensureVisible(find.byKey(const Key('interest_observation_add_b')));
      await tester.tap(find.byKey(const Key('interest_observation_add_b')));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('interest_observation_field_b')), 'Subir a pé');
      await tester.ensureVisible(find.byKey(const Key('interest_observation_save_b')));
      await tester.tap(find.byKey(const Key('interest_observation_save_b')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('interest_observation_field_b')), findsOneWidget);
      expect(find.text('Could not save the note. Please try again.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  testWidgets('does not show its own edit button — editing route lives only in the app bar', (
    tester,
  ) async {
    final travel = TravelViewModel.fromDomain(_travel());

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TravelsController(),
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RouteViewTab(travel: travel)),
        ),
      ),
    );

    expect(find.text('Edit Route Plan'), findsNothing);
    expect(find.byIcon(Icons.edit_road), findsNothing);
    expect(find.text('Lisbon'), findsOneWidget);
  });
}
