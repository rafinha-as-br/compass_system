import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/home/presentation/controllers/home_controller.dart';
import 'package:routecraft_app/features/home/presentation/pages/home_page.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/travel_repository.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/widgets/skeleton_block.dart';

/// Fails once, then succeeds — models a transient network error recovering
/// after the user taps retry.
class _FakeSuccessAfterFailureRepository implements TravelRepository {
  var _calls = 0;

  @override
  Future<Result<List<Travel>>> getTravelsForClient(String clientName) async {
    _calls++;
    if (_calls == 1) return const Result.failure('Erro de rede');
    return Result.success([_travel('Litoral Norte', TravelStatus.travelStarted)]);
  }

  @override
  Future<Result<Travel>> getTravel(String id) async => throw UnimplementedError();

  @override
  Future<Result<Travel>> createTravel(Travel travel) async => throw UnimplementedError();
}

Widget _wrap(HomeController controller, {Locale? locale}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: HomePage(controller: controller),
  );
}

/// Wraps HomePage in a real two-branch shell (Início/Viagens) — needed to
/// exercise the "Ver minhas viagens" link, which switches branch via
/// `StatefulNavigationShell.of(context)` and has no ancestor shell under
/// plain `_wrap`.
Widget _wrapWithShell(HomeController controller) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => navigationShell,
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.home, builder: (context, state) => HomePage(controller: controller)),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.travels, builder: (context, state) => const Text('Viagens stand-in')),
          ]),
        ],
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
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
        destination: 'Paraty',
        interestsList: const [],
      ),
    );

class _FakeTravelRepository implements TravelRepository {
  Result<List<Travel>>? nextResult;

  @override
  Future<Result<List<Travel>>> getTravelsForClient(String clientName) async => nextResult!;

  @override
  Future<Result<Travel>> getTravel(String id) async => throw UnimplementedError();

  @override
  Future<Result<Travel>> createTravel(Travel travel) async => throw UnimplementedError();
}

void main() {
  testWidgets('shows a skeleton, not a spinner, while fetching', (tester) async {
    await tester.pumpWidget(_wrap(HomeController.withState(const HomeState())));

    expect(find.byType(SkeletonBlock), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows the network-error state with a retry button, and no floating action button', (tester) async {
    await tester.pumpWidget(_wrap(HomeController.withState(const HomeState(isLoading: false, isError: true))));
    await tester.pump();

    expect(find.text("Couldn't load this"), findsOneWidget);
    expect(find.text('Check your connection and try again.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('tapping "Try again" retries the fetch and shows the travels on success', (tester) async {
    final repository = _FakeSuccessAfterFailureRepository();
    final controller = HomeController(
      travelUseCases: TravelUseCases(repository),
      getClientName: () async => 'Rafaela Souza',
    );

    await tester.pumpWidget(_wrap(controller));
    await tester.pump();

    expect(find.text("Couldn't load this"), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Litoral Norte'), findsOneWidget);
  });

  testWidgets('shows the "no routes yet" empty state when the client never created a travel', (tester) async {
    await tester.pumpWidget(_wrap(
      HomeController.withState(const HomeState(isLoading: false, clientName: 'Rafaela Souza')),
    ));
    await tester.pump();

    expect(find.text('No routes yet'), findsOneWidget);
    expect(find.text('Create your first route to start traveling.'), findsOneWidget);
    expect(find.text('Create route'), findsOneWidget);
    expect(find.text('See my trips'), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('shows the "no trip in progress" empty state with a link to Viagens when the client has travels '
      'but none in progress', (tester) async {
    final state = HomeState(
      isLoading: false,
      clientName: 'Rafaela Souza',
      upcoming: [_travel('Serra Gaúcha', TravelStatus.routeCreated)],
    );

    await tester.pumpWidget(_wrapWithShell(HomeController.withState(state)));
    await tester.pump();

    expect(find.text('No trip in progress'), findsOneWidget);
    expect(find.text('Your upcoming trips are in the Trips tab.'), findsOneWidget);
    expect(find.text('Create route'), findsOneWidget);

    await tester.tap(find.text('See my trips'));
    await tester.pumpAndSettle();

    expect(find.text('Viagens stand-in'), findsOneWidget);
  });

  testWidgets('renders the greeting with the first name and avatar initials', (tester) async {
    await tester.pumpWidget(_wrap(
      HomeController.withState(const HomeState(isLoading: false, clientName: 'Rafaela Souza')),
    ));
    await tester.pump();

    expect(find.text('Hello, Rafaela'), findsOneWidget);
    expect(find.text('RS'), findsOneWidget);
  });

  testWidgets('shows the offline banner with the synced-at date instead of the network-error state', (tester) async {
    final state = HomeState(
      isLoading: false,
      clientName: 'Rafaela Souza',
      isOffline: true,
      syncedAt: DateTime(2026, 10, 13),
      inProgress: [_travel('Serra Gaúcha', TravelStatus.travelStarted)],
    );

    await tester.pumpWidget(_wrap(HomeController.withState(state)));
    await tester.pump();

    expect(find.text('Offline · data from 13 Oct 2026'), findsOneWidget);
    expect(find.text("Couldn't load this"), findsNothing);
    expect(find.text('Serra Gaúcha'), findsOneWidget);
  });

  testWidgets('shows only the in-progress travel — Próximas/Concluídas moved to the Viagens tab (CPS-131)',
      (tester) async {
    final state = HomeState(
      isLoading: false,
      clientName: 'Rafaela Souza',
      inProgress: [_travel('Litoral Norte', TravelStatus.travelStarted)],
      upcoming: [_travel('Serra Gaúcha', TravelStatus.routeCreated)],
      completed: [_travel('Chapada Diamantina', TravelStatus.travelFinished)],
    );

    await tester.pumpWidget(_wrap(HomeController.withState(state)));
    await tester.pump();

    expect(find.text('IN PROGRESS'), findsOneWidget);
    expect(find.text('UPCOMING'), findsNothing);
    expect(find.text('COMPLETED'), findsNothing);
    expect(find.text('Litoral Norte'), findsOneWidget);
    expect(find.text('Serra Gaúcha'), findsNothing);
    expect(find.text('Chapada Diamantina'), findsNothing);
    // The FAB moved to the Viagens tab (CPS-127) — Início no longer has one.
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('with more than one trip in progress, shows the one that started first', (tester) async {
    final repository = _FakeTravelRepository()
      ..nextResult = Result.success([
        _travel('Serra Gaúcha', TravelStatus.travelStarted, startDate: DateTime(2026, 11, 1)),
        _travel('Litoral Norte', TravelStatus.travelStarted, startDate: DateTime(2026, 10, 12)),
      ]);
    final controller = HomeController(
      travelUseCases: TravelUseCases(repository),
      getClientName: () async => 'Rafaela Souza',
    );

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    expect(find.text('Litoral Norte'), findsOneWidget);
    expect(find.text('Serra Gaúcha'), findsNothing);
  });

  testWidgets('renders the greeting and route/period localized in Portuguese', (tester) async {
    final state = HomeState(
      isLoading: false,
      clientName: 'Rafaela Souza',
      inProgress: [_travel('Serra Gaúcha', TravelStatus.travelStarted)],
    );

    await tester.pumpWidget(_wrap(HomeController.withState(state), locale: const Locale('pt')));
    await tester.pump();

    expect(find.text('Olá, Rafaela'), findsOneWidget);
    expect(find.text('EM ANDAMENTO'), findsOneWidget);
    expect(find.text('São Paulo → Paraty'), findsOneWidget);
    expect(find.text('12–19 out'), findsOneWidget);
  });

  testWidgets('refetches after returning from route creation, picking up the new travel', (tester) async {
    final repository = _FakeTravelRepository()..nextResult = Result.success(const []);
    final controller = HomeController(
      travelUseCases: TravelUseCases(repository),
      getClientName: () async => 'Rafaela Souza',
    );
    final router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => HomePage(controller: controller),
          routes: [
            GoRoute(
              path: AppRoutes.createRoute,
              // Stands in for RouteCreationPage: pops itself right away, as
              // if a route had just been created.
              builder: (context, state) {
                WidgetsBinding.instance.addPostFrameCallback((_) => context.pop());
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    await tester.pumpAndSettle();
    expect(find.text('No routes yet'), findsOneWidget);

    // routeCreated is not "in progress" — Início shows the cenário 2 empty
    // state instead of the new travel's card (it lives in the Viagens tab).
    repository.nextResult = Result.success([_travel('Nova Rota', TravelStatus.routeCreated)]);
    await tester.tap(find.text('Create route'));
    await tester.pumpAndSettle();

    expect(find.text('No trip in progress'), findsOneWidget);
    expect(find.text('Nova Rota'), findsNothing);
  });
}
