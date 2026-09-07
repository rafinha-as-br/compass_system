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

  testWidgets('shows the empty state with no floating action button when there are no travels', (tester) async {
    await tester.pumpWidget(_wrap(
      HomeController.withState(const HomeState(isLoading: false, clientName: 'Rafaela Souza')),
    ));
    await tester.pump();

    expect(find.text('No travels yet.'), findsOneWidget);
    expect(find.text('Create my first route'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('renders the greeting with the first name and avatar initials', (tester) async {
    await tester.pumpWidget(_wrap(
      HomeController.withState(const HomeState(isLoading: false, clientName: 'Rafaela Souza')),
    ));
    await tester.pump();

    expect(find.text('Hello, Rafaela'), findsOneWidget);
    expect(find.text('RS'), findsOneWidget);
  });

  testWidgets('groups travels into sections, in urgency order, without empty sections', (tester) async {
    final state = HomeState(
      isLoading: false,
      clientName: 'Rafaela Souza',
      inProgress: [_travel('Litoral Norte', TravelStatus.travelStarted)],
      upcoming: [_travel('Serra Gaúcha', TravelStatus.routeCreated)],
      completed: const [],
    );

    await tester.pumpWidget(_wrap(HomeController.withState(state)));
    await tester.pump();

    expect(find.text('IN PROGRESS'), findsOneWidget);
    expect(find.text('UPCOMING'), findsOneWidget);
    expect(find.text('COMPLETED'), findsNothing);

    final inProgressY = tester.getTopLeft(find.text('IN PROGRESS')).dy;
    final upcomingY = tester.getTopLeft(find.text('UPCOMING')).dy;
    expect(inProgressY, lessThan(upcomingY));

    expect(find.text('Litoral Norte'), findsOneWidget);
    expect(find.text('Serra Gaúcha'), findsOneWidget);
    expect(find.text('São Paulo → Paraty · 12–19 Oct'), findsNWidgets(2));
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('renders the greeting and route summary localized in Portuguese', (tester) async {
    final state = HomeState(
      isLoading: false,
      clientName: 'Rafaela Souza',
      upcoming: [_travel('Serra Gaúcha', TravelStatus.routeCreated)],
    );

    await tester.pumpWidget(_wrap(HomeController.withState(state), locale: const Locale('pt')));
    await tester.pump();

    expect(find.text('Olá, Rafaela'), findsOneWidget);
    expect(find.text('PRÓXIMAS'), findsOneWidget);
    expect(find.text('São Paulo → Paraty · 12–19 out'), findsOneWidget);
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
    expect(find.text('No travels yet.'), findsOneWidget);

    repository.nextResult = Result.success([_travel('Nova Rota', TravelStatus.routeCreated)]);
    await tester.tap(find.text('Create my first route'));
    await tester.pumpAndSettle();

    expect(find.text('Nova Rota'), findsOneWidget);
  });
}
