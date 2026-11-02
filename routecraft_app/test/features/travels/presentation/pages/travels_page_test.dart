import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/travel_repository.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';
import 'package:routecraft_app/features/travels/presentation/controllers/travels_controller.dart';
import 'package:routecraft_app/features/travels/presentation/pages/travels_page.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

Widget _wrap(TravelsController controller) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: TravelsPage(controller: controller),
  );
}

Travel _travel(String name, TravelStatus status, {DateTime? startDate}) => Travel(
      domainId: name,
      backEndId: name,
      clientName: 'Maria Silva',
      travelName: name,
      travelStatus: status,
      participantsList: const [],
      routePlan: RoutePlan(
        domainId: '$name-route',
        backEndId: null,
        startDate: startDate ?? DateTime(2026, 10, 12),
        endDate: (startDate ?? DateTime(2026, 10, 12)).add(const Duration(days: 7)),
        startLocation: 'São Paulo',
        destination: 'Lisbon',
        interestsList: const [],
      ),
    );

class _CountingRepository implements TravelRepository {
  _CountingRepository(this.travels);

  final List<Travel> travels;
  var calls = 0;

  @override
  Future<Result<List<Travel>>> getTravelsForClient(String clientName) async {
    calls++;
    return Result.success(travels);
  }

  @override
  Future<Result<Travel>> getTravel(String id) async => throw UnimplementedError();

  @override
  Future<Result<Travel>> createTravel(Travel travel) async => throw UnimplementedError();
}

void main() {
  testWidgets('shows a loading indicator while fetching', (tester) async {
    await tester.pumpWidget(_wrap(TravelsController.withState(const TravelsState())));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the network-error state with a retry button, and no FAB', (tester) async {
    await tester.pumpWidget(_wrap(TravelsController.withState(const TravelsState(isLoading: false, isError: true))));
    await tester.pump();

    expect(find.text("Couldn't load this"), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('shows the empty state with no FAB when the client has no travels at all', (tester) async {
    await tester.pumpWidget(_wrap(TravelsController.withState(const TravelsState(isLoading: false))));
    await tester.pump();

    expect(find.text('No travels yet.'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('lists every travel, completed ones included, with search and filter chips', (tester) async {
    final controller = TravelsController.withState(TravelsState(
      isLoading: false,
      travels: [
        _travel('Chapada Diamantina', TravelStatus.travelFinished),
        _travel('Serra Gaúcha', TravelStatus.routeCreated),
      ],
    ));

    await tester.pumpWidget(_wrap(controller));
    await tester.pump();

    expect(find.text('Chapada Diamantina'), findsOneWidget);
    expect(find.text('Serra Gaúcha'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'chapada');
    await tester.pump();

    expect(find.text('Chapada Diamantina'), findsOneWidget);
    expect(find.text('Serra Gaúcha'), findsNothing);
  });

  testWidgets('status filter chip narrows the list', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = TravelsController.withState(TravelsState(
      isLoading: false,
      travels: [
        _travel('Chapada Diamantina', TravelStatus.travelFinished),
        _travel('Serra Gaúcha', TravelStatus.routeCreated),
      ],
    ));

    await tester.pumpWidget(_wrap(controller));
    await tester.pump();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Completed'));
    await tester.pump();

    expect(find.text('Chapada Diamantina'), findsOneWidget);
    expect(find.text('Serra Gaúcha'), findsNothing);
  });

  testWidgets('shows a dedicated message when the search/filter matches nothing', (tester) async {
    final controller = TravelsController.withState(TravelsState(
      isLoading: false,
      travels: [_travel('Chapada Diamantina', TravelStatus.travelFinished)],
      searchQuery: 'não existe',
    ));

    await tester.pumpWidget(_wrap(controller));
    await tester.pump();

    expect(find.text('No travels match your search.'), findsOneWidget);
  });

  testWidgets('pulling the list down re-fetches the travels (pull-to-refresh)', (tester) async {
    final repository = _CountingRepository([_travel('Litoral Norte', TravelStatus.travelStarted)]);
    final controller = TravelsController(travelUseCases: TravelUseCases(repository), getClientName: () async => 'Maria Silva');
    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();
    expect(repository.calls, 1);

    await tester.fling(find.text('Litoral Norte'), const Offset(0, 400), 1000);
    await tester.pump();
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
    expect(find.text('Litoral Norte'), findsOneWidget);
  });

  testWidgets('pull-to-refresh also works on the empty state', (tester) async {
    final repository = _CountingRepository(const []);
    final controller = TravelsController(travelUseCases: TravelUseCases(repository), getClientName: () async => 'Maria Silva');
    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    await tester.fling(find.text('No travels yet.'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
  });
}
