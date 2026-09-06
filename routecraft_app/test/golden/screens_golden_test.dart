import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/app/controllers/settings_controller.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/account/presentation/controllers/account_controller.dart';
import 'package:routecraft_app/features/account/presentation/pages/account_page.dart';
import 'package:routecraft_app/features/travels/domain/entities/itinerary.dart';
import 'package:routecraft_app/features/travels/domain/entities/itinerary_step.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/transport.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:routecraft_app/features/auth/presentation/controllers/login_controller.dart';
import 'package:routecraft_app/features/auth/presentation/pages/login_page.dart';
import 'package:routecraft_app/features/home/presentation/controllers/home_controller.dart';
import 'package:routecraft_app/features/home/presentation/pages/home_page.dart';
import 'package:routecraft_app/features/itinerary_hub/presentation/pages/itinerary_hub_page.dart';
import 'package:routecraft_app/features/itinerary_timeline/presentation/pages/itinerary_timeline_page.dart';
import 'package:routecraft_app/features/route_creation/presentation/controllers/route_creation_controller.dart';
import 'package:routecraft_app/features/route_creation/presentation/pages/route_creation_page.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';

import '../support/stub_auth_repository.dart';

/// Golden coverage das telas centrais do rebrand: login, visualização de
/// viagem e criação de rota, nas duas variantes de tema. Um smoke test de
/// boot completo já existe em widget_test.dart; aqui é regressão visual.

Travel _sampleTravel() => Travel(
      domainId: 't1',
      backEndId: 't1',
      clientName: 'Maria Silva',
      travelName: 'Trip to Rome',
      travelStatus: TravelStatus.itineraryCreated,
      participantsList: const [],
      routePlan: RoutePlan(
        domainId: 'r1',
        backEndId: 'r1',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 10),
        startLocation: 'São Paulo',
        destination: 'Rome',
        interestsList: const [],
      ),
      itinerary: Itinerary(
        domainId: 'it1',
        backEndId: 'it1',
        agentName: 'Ana',
        itinerarySteps: [
          // ponytail: fixed far-past date, not DateTime.now() + offset — the
          // hub computes "days until" against the real clock at render time,
          // so a relative fixture date would make this golden's rendered
          // text (and the PNG) drift and fail on a different day. A past
          // date pins the render to the stable "today" branch forever.
          ItineraryStep.newTravelSegment(
            domainId: 's1',
            backEndId: 's1',
            title: 'Flight to Rome',
            startDate: DateTime(2020, 1, 1),
            finishDate: DateTime(2020, 1, 1, 10),
            finished: false,
            startPoint: 'GRU',
            finishPoint: 'FCO',
            transport: Transport.newAirplane(
              domainId: 'tr1',
              backEndId: 'tr1',
              flightNumber: 'LA3421',
              flightCompany: 'LATAM',
              flightDate: DateTime(2020, 1, 1),
              departureGate: 'A12',
              departureAirport: 'GRU',
              arrivalAirport: 'FCO',
            ),
          ),
        ],
      ),
    );

Widget _loginScreen() => LoginPage(
      controller: LoginController(
        loginUseCase: LoginUseCase(StubAuthRepository(const Result.failure(''))),
        saveToken: (_) async {},
      ),
    );

Widget _hubRouteCreatedScreen() => ItineraryHubPage(
      travel: Travel(
        domainId: 't2',
        backEndId: 't2',
        clientName: 'Rafaela Souza',
        travelName: 'Litoral Norte',
        travelStatus: TravelStatus.routeCreated,
        participantsList: const [],
        routePlan: RoutePlan(
          domainId: 'r2',
          backEndId: 'r2',
          startDate: DateTime(2026, 10, 12),
          endDate: DateTime(2026, 10, 19),
          startLocation: 'São Paulo',
          destination: 'Paraty',
          interestsList: [
            InterestPoint(domainId: 'i1', backEndId: null, name: 'Trilha', description: ''),
            InterestPoint(domainId: 'i2', backEndId: null, name: 'Gastronomia', description: ''),
            InterestPoint(domainId: 'i3', backEndId: null, name: 'Centro histórico', description: ''),
          ],
        ),
      ),
    );

Widget _hubItineraryCreatedScreen() => ItineraryHubPage(travel: _sampleTravel());

Widget _timelineWithStepsScreen() => ItineraryTimelinePage(travel: _sampleTravel());

Widget _timelineEmptyDayScreen() => ItineraryTimelinePage(
      travel: Travel(
        domainId: 't3',
        backEndId: 't3',
        clientName: 'Rafaela Souza',
        travelName: 'Trip to Rome',
        travelStatus: TravelStatus.itineraryCreated,
        participantsList: const [],
        routePlan: RoutePlan(
          domainId: 'r3',
          backEndId: 'r3',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 3),
          startLocation: 'São Paulo',
          destination: 'Rome',
          interestsList: const [],
        ),
        itinerary: Itinerary(domainId: 'it3', backEndId: 'it3', agentName: 'Ana', itinerarySteps: const []),
      ),
    );

Widget _routeCreationScreen() => RouteCreationPage(
      controller: RouteCreationController.withState(const RouteCreationState()),
    );

Widget _accountScreen() => ChangeNotifierProvider<SettingsController>(
      create: (_) => SettingsController(),
      child: AccountPage(
        controller: AccountController.withState(
          const AccountState(
            isLoading: false,
            clientName: 'Rafaela Souza',
            clientEmail: 'rafaela@email.com',
            agentName: 'Marcos Cardoso',
          ),
        ),
      ),
    );

Widget _routeCreationReviewScreen() {
  final controller = RouteCreationController.withState(
    const RouteCreationState(currentStep: routeCreationStepCount),
  );
  controller.tripNameController.text = 'Litoral Norte com a família';
  controller.startLocationController.text = 'São Paulo';
  controller.destinationController.text = 'Paraty, RJ';
  controller.setStartDate(DateTime(2026, 10, 12));
  controller.setEndDate(DateTime(2026, 10, 19));
  controller.addInterestPoint('Trilha', '');
  controller.addInterestPoint('Gastronomia', '');
  controller.addInterestPoint('Centro histórico', '');
  return RouteCreationPage(controller: controller);
}

Widget _homeScreen() => HomePage(
      controller: HomeController.withState(
        HomeState(
          isLoading: false,
          clientName: 'Rafaela Souza',
          inProgress: [
            Travel(
              domainId: 't2',
              backEndId: 't2',
              clientName: 'Rafaela Souza',
              travelName: 'Litoral Norte',
              travelStatus: TravelStatus.travelStarted,
              participantsList: const [],
              routePlan: RoutePlan(
                domainId: 'r2',
                backEndId: 'r2',
                startDate: DateTime(2026, 10, 12),
                endDate: DateTime(2026, 10, 19),
                startLocation: 'São Paulo',
                destination: 'Paraty',
                interestsList: const [],
              ),
            ),
          ],
          upcoming: [_sampleTravel()],
        ),
      ),
    );

Widget _homeSkeletonScreen() => HomePage(controller: HomeController.withState(const HomeState()));

Widget _homeErrorScreen() =>
    HomePage(controller: HomeController.withState(const HomeState(isLoading: false, isError: true)));

final _screens = <String, Widget Function()>{
  'login': _loginScreen,
  'home': _homeScreen,
  'home_skeleton': _homeSkeletonScreen,
  'home_error': _homeErrorScreen,
  'hub_route_created': _hubRouteCreatedScreen,
  'hub_itinerary_created': _hubItineraryCreatedScreen,
  'timeline_with_steps': _timelineWithStepsScreen,
  'timeline_empty_day': _timelineEmptyDayScreen,
  'route_creation': _routeCreationScreen,
  'route_creation_review': _routeCreationReviewScreen,
  'account': _accountScreen,
};

// ponytail: TestWidgetsFlutterBinding bloqueia todo HttpClient real durante
// os testes, então o fetch de rede que AppTheme.lightTheme/darkTheme disparam
// (via GoogleFonts.poppinsTextTheme, como efeito colateral só de construir o
// ThemeData) nunca completa aqui e derruba o teste com exceção não tratada —
// mesmo que o resultado seja descartado depois. Por isso os goldens replicam
// aqui só a parte visual que importa para regressão de marca (cores,
// brightness, AppBar) usando a tipografia Material padrão, sem nunca chamar
// AppTheme.lightTheme/darkTheme nem tocar em google_fonts.
// Upgrade: se algum dia precisar comparar a Poppins pixel-a-pixel, bundlar
// os .ttf em assets/fonts e registrar via FontLoader num setUpAll.
ThemeData _goldenLightTheme() => ThemeData(
      brightness: Brightness.light,
      primaryColor: TravelAppColors.primary,
      scaffoldBackgroundColor: TravelAppColors.background,
      colorScheme: const ColorScheme.light(
        primary: TravelAppColors.primary,
        secondary: TravelAppColors.accentGold,
        surface: TravelAppColors.surface,
        error: TravelAppColors.error,
        onPrimary: TravelAppColors.textOnPrimary,
        onSecondary: TravelAppColors.textPrimary,
        onSurface: TravelAppColors.textPrimary,
        onError: TravelAppColors.textOnPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TravelAppColors.primary,
        foregroundColor: TravelAppColors.textOnPrimary,
        elevation: 0,
      ),
    );

ThemeData _goldenDarkTheme() => ThemeData(
      brightness: Brightness.dark,
      primaryColor: TravelAppColors.primaryDark,
      scaffoldBackgroundColor: TravelAppColors.surfaceDark,
      colorScheme: const ColorScheme.dark(
        primary: TravelAppColors.primaryLight,
        secondary: TravelAppColors.accentGoldLight,
        surface: TravelAppColors.surfaceDark,
        error: TravelAppColors.error,
        onPrimary: TravelAppColors.textOnPrimary,
        onSecondary: TravelAppColors.textPrimary,
        onSurface: TravelAppColors.textOnDark,
        onError: TravelAppColors.textOnPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TravelAppColors.surfaceDark,
        foregroundColor: TravelAppColors.textOnDark,
        elevation: 0,
      ),
    );

final _themes = <String, ThemeData Function()>{
  'light': _goldenLightTheme,
  'dark': _goldenDarkTheme,
};

void main() {
  for (final themeEntry in _themes.entries) {
    for (final screenEntry in _screens.entries) {
      testWidgets('${screenEntry.key} (${themeEntry.key}) matches golden', (tester) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(MaterialApp(
          theme: themeEntry.value(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: screenEntry.value(),
        ));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/${screenEntry.key}_${themeEntry.key}.png'),
        );
      });
    }
  }
}
