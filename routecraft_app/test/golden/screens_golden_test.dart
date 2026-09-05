import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:routecraft_app/features/auth/presentation/controllers/login_controller.dart';
import 'package:routecraft_app/features/auth/presentation/pages/login_page.dart';
import 'package:routecraft_app/features/route_creation/presentation/controllers/route_creation_controller.dart';
import 'package:routecraft_app/features/route_creation/presentation/pages/route_creation_page.dart';
import 'package:routecraft_app/features/visualization/presentation/controllers/visualization_controller.dart';
import 'package:routecraft_app/features/visualization/presentation/pages/visualization_page.dart';
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
    );

Widget _loginScreen() => LoginPage(
      controller: LoginController(
        loginUseCase: LoginUseCase(StubAuthRepository(const Result.failure(''))),
        saveToken: (_) async {},
      ),
    );

Widget _visualizationScreen() => VisualizationPage(
      controller: VisualizationController.withState(
        VisualizationState(isLoading: false, travels: [_sampleTravel()]),
      ),
    );

Widget _routeCreationScreen() => RouteCreationPage(
      controller: RouteCreationController.withState(const RouteCreationState()),
    );

final _screens = <String, Widget Function()>{
  'login': _loginScreen,
  'visualization': _visualizationScreen,
  'route_creation': _routeCreationScreen,
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
