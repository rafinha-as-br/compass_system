import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_route.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_travel.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/pages/builds/travel_creation_page.dart';
import 'package:travel_matrix/features/users/domain/entities/user.dart';
import 'package:travel_matrix/features/users/domain/entities/user_stats.dart';
import 'package:travel_matrix/features/users/domain/entities/user_status.dart';
import 'package:travel_matrix/features/users/domain/user_client_repository.dart';
import 'package:travel_matrix/features/users/domain/user_crud_use_cases.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class _MockCrudTravelUseCases extends Mock implements CrudTravelUseCases {}

class _MockCrudRoute extends Mock implements CrudRoute {}

class _MockUserClientRepository extends Mock implements UserClientRepository {}

UserClient _buildClient() {
  return UserClient(
    backEndId: 'client-1',
    domainId: 'client-1',
    name: 'Maria Silva',
    cpf: '123',
    sex: 'F',
    phoneNumber: '11999999999',
    status: UserClientStatus(status: ActiveStatus(), lastLogin: null),
    email: 'maria@compass.com',
    travels: const [],
    stats: UserStats(totalTravels: 0, uniqueDestinationsCount: 0),
  );
}

void main() {
  late _MockCrudTravelUseCases travelUseCases;
  late _MockCrudRoute routeUseCases;
  late _MockUserClientRepository userRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthStorageService.init();
    registerFallbackValue(<String, dynamic>{});

    travelUseCases = _MockCrudTravelUseCases();
    routeUseCases = _MockCrudRoute();
    userRepository = _MockUserClientRepository();

    when(() => travelUseCases.readAll()).thenAnswer((_) async => Result.success(<Travel>[]));
    when(() => userRepository.getAllUsers()).thenAnswer((_) async => Result.success([_buildClient()]));
  });

  Widget wrap(AuthController auth) {
    final travelsController = TravelsController(travelUseCases: travelUseCases, routeUseCases: routeUseCases);
    final router = GoRouter(
      initialLocation: '/create',
      routes: [
        GoRoute(
          path: '/create',
          builder: (context, state) => TravelCreationPage(userUseCases: UserUseCases(userRepository)),
        ),
        GoRoute(path: '/travels', builder: (context, state) => const SizedBox()),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: auth),
        ChangeNotifierProvider<TravelsController>.value(value: travelsController),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  testWidgets('submitting sends the agent id from AuthController, not a fresh lookup', (tester) async {
    when(() => travelUseCases.createFromRequest(any()))
        .thenAnswer((_) async => Result.success(_fakeTravel()));

    final auth = AuthController();
    auth.debugSetUserData({'id': 'agent-9', 'name': 'Carlos Agent', 'email': 'carlos@compass.com'});

    await tester.pumpWidget(wrap(auth));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Travel Name'), 'Lisbon 2025');
    await tester.enterText(find.widgetWithText(TextFormField, 'Start Location'), 'Sao Paulo');
    await tester.enterText(find.widgetWithText(TextFormField, 'Destination'), 'Lisbon');

    await tester.ensureVisible(find.text('CREATE TRAVEL'));
    await tester.tap(find.text('CREATE TRAVEL'));
    await tester.pumpAndSettle();

    final captured = verify(() => travelUseCases.createFromRequest(captureAny())).captured;
    final request = captured.single as Map<String, dynamic>;
    expect(request['agentId'], 'agent-9');
  });

  testWidgets('submitting without an authenticated agent shows an error and never calls the backend', (
    tester,
  ) async {
    final auth = AuthController();
    auth.debugSetUserData(null);

    await tester.pumpWidget(wrap(auth));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Travel Name'), 'Lisbon 2025');
    await tester.enterText(find.widgetWithText(TextFormField, 'Start Location'), 'Sao Paulo');
    await tester.enterText(find.widgetWithText(TextFormField, 'Destination'), 'Lisbon');

    await tester.ensureVisible(find.text('CREATE TRAVEL'));
    await tester.tap(find.text('CREATE TRAVEL'));
    await tester.pumpAndSettle();

    verifyNever(() => travelUseCases.createFromRequest(any()));
    expect(find.text('Session expired. Please sign in again.'), findsOneWidget);
  });
}

Travel _fakeTravel() {
  return Travel(
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
}
