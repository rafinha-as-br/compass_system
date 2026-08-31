import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/app/app_injector.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/features/travels/domain/repository/route_repository.dart';
import 'package:travel_matrix/features/travels/domain/repository/travel_repository.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_route.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_travel.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/pages/travels_dashboard_page.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class _MockTravelRepository extends Mock implements TravelRepository {}

class _MockRouteRepository extends Mock implements RouteRepository {}

Travel _travel(String id) => Travel(
      domainId: id,
      backEndId: id,
      clientName: 'Maria Silva',
      travelName: 'Litoral Norte',
      travelStatus: TravelStatus.routeCreated,
      routePlan: RoutePlan(
        domainId: 'route-$id',
        backEndId: 'route-$id',
        startDate: DateTime(2026, 1, 10),
        endDate: DateTime(2026, 1, 20),
        startLocation: 'São Paulo',
        destination: 'Ubatuba',
        interestsList: const [],
      ),
      participantsList: const [],
    );

Widget _wrap(TravelsController controller) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthController()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: TravelsDashboardPage(controller: controller)),
    ),
  );
}

void main() {
  late _MockTravelRepository travelRepository;
  late _MockRouteRepository routeRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppInjector.init();
    travelRepository = _MockTravelRepository();
    routeRepository = _MockRouteRepository();
  });

  testWidgets('renders the travels listing without crashing once loading succeeds', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    when(() => travelRepository.getAllTravels())
        .thenAnswer((_) async => Result.success([_travel('1'), _travel('2')]));
    final controller = TravelsController(
      travelUseCases: CrudTravelUseCases(travelRepository),
      routeUseCases: CrudRoute(routeRepository),
    );

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    expect(find.text('Litoral Norte'), findsNWidgets(2));
    expect(find.text('Maria Silva'), findsNWidgets(2));
  });

  testWidgets('renders the empty state without crashing when there are no travels', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    when(() => travelRepository.getAllTravels()).thenAnswer((_) async => Result.success(const []));
    final controller = TravelsController(
      travelUseCases: CrudTravelUseCases(travelRepository),
      routeUseCases: CrudRoute(routeRepository),
    );

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();
  });

  testWidgets('shows a localized generic message instead of raw text when loading fails', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    when(() => travelRepository.getAllTravels())
        .thenAnswer((_) async => const Result.failure('ClientException: Failed to fetch, uri=http://api'));
    final controller = TravelsController(
      travelUseCases: CrudTravelUseCases(travelRepository),
      routeUseCases: CrudRoute(routeRepository),
    );

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    expect(find.text('Unable to load travels right now. Please try again later.'), findsOneWidget);
    expect(find.textContaining('ClientException'), findsNothing);
  });
}
