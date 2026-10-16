import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/app/global_controllers/notifications_badge_controller.dart';
import 'package:travel_matrix/app/global_controllers/sidebar_controller.dart';
import 'package:travel_matrix/app/router/private_shell_scaffold.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/core/services/settings_storage_service.dart';
import 'package:travel_matrix/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class _MockNotificationUseCases extends Mock implements NotificationUseCases {}

Future<GoRouter> _pumpShell(
  WidgetTester tester,
  AuthController auth, {
  Size size = const Size(1280, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final notificationUseCases = _MockNotificationUseCases();
  when(() => notificationUseCases.getUnreadCount()).thenAnswer((_) async => const Result.success(0));

  final router = GoRouter(
    initialLocation: '/a',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => PrivateShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/a', builder: (_, __) => const SizedBox())]),
          StatefulShellBranch(routes: [GoRoute(path: '/b', builder: (_, __) => const SizedBox())]),
          StatefulShellBranch(routes: [GoRoute(path: '/c', builder: (_, __) => const SizedBox())]),
          StatefulShellBranch(routes: [GoRoute(path: '/d', builder: (_, __) => const SizedBox())]),
          StatefulShellBranch(routes: [GoRoute(path: '/e', builder: (_, __) => const SizedBox())]),
        ],
      ),
    ],
  );

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: auth),
        ChangeNotifierProvider(create: (_) => SidebarController()),
        ChangeNotifierProvider(create: (_) => NotificationsBadgeController(useCases: notificationUseCases)),
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
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthStorageService.init();
    SettingsStorageService.resetForTesting();
    await SettingsStorageService.init();
  });

  testWidgets('renders the sidebar header without a logo, with 4 nav items (Empresa after Users, no Configurações)', (tester) async {
    final auth = AuthController();
    auth.debugSetUserData({'id': 'agent-1', 'name': 'Carlos Agent', 'email': 'carlos@compass.com'});

    await _pumpShell(tester, auth);

    expect(tester.takeException(), isNull);
    expect(find.byType(Image), findsNothing);
    expect(find.text('Compass System'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Booking'), findsOneWidget);
    expect(find.text('Users'), findsOneWidget);
    expect(find.text('Company'), findsOneWidget);
    expect(find.text('Settings'), findsNothing);
    expect(find.text('Support'), findsNothing);
    expect(find.text('Logout'), findsNothing);
  });

  testWidgets('tapping the account row opens the popup with the 5 items in order', (tester) async {
    final auth = AuthController();
    auth.debugSetUserData({'id': 'agent-1', 'name': 'Carlos Agent', 'email': 'carlos@compass.com'});

    await _pumpShell(tester, auth);
    await tester.tap(find.text('Carlos Agent'));
    await tester.pumpAndSettle();

    final myAccountY = tester.getTopLeft(find.text('My Account')).dy;
    final settingsY = tester.getTopLeft(find.text('Settings')).dy;
    final supportY = tester.getTopLeft(find.text('Support')).dy;
    final logoutY = tester.getTopLeft(find.text('Logout')).dy;

    expect(myAccountY, lessThan(settingsY));
    expect(settingsY, lessThan(supportY));
    expect(supportY, lessThan(logoutY));
    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets('"Minha Conta" and "Configurações" navigate to /account and close the popup', (tester) async {
    final auth = AuthController();
    auth.debugSetUserData({'id': 'agent-1', 'name': 'Carlos Agent', 'email': 'carlos@compass.com'});

    final router = await _pumpShell(tester, auth);
    await tester.tap(find.text('Carlos Agent'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('My Account'));
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/e');
    expect(find.text('My Account'), findsNothing);
  });

  testWidgets('"Sair" calls logout and closes the popup', (tester) async {
    final auth = AuthController();
    auth.debugSetUserData({'id': 'agent-1', 'name': 'Carlos Agent', 'email': 'carlos@compass.com'});

    await _pumpShell(tester, auth);
    await tester.tap(find.text('Carlos Agent'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(auth.isAuthenticated, isFalse);
    expect(find.text('Logout'), findsNothing);
  });

  testWidgets('Esc closes the popup', (tester) async {
    final auth = AuthController();
    auth.debugSetUserData({'id': 'agent-1', 'name': 'Carlos Agent', 'email': 'carlos@compass.com'});

    await _pumpShell(tester, auth);
    await tester.tap(find.text('Carlos Agent'));
    await tester.pumpAndSettle();
    expect(find.text('My Account'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('My Account'), findsNothing);
  });

  testWidgets('tapping outside the popup closes it', (tester) async {
    final auth = AuthController();
    auth.debugSetUserData({'id': 'agent-1', 'name': 'Carlos Agent', 'email': 'carlos@compass.com'});

    await _pumpShell(tester, auth);
    await tester.tap(find.text('Carlos Agent'));
    await tester.pumpAndSettle();
    expect(find.text('My Account'), findsOneWidget);

    await tester.tapAt(const Offset(600, 300));
    await tester.pumpAndSettle();

    expect(find.text('My Account'), findsNothing);
  });

  testWidgets('tapping outside still closes the popup after several reopen cycles (CPS-112 QA regression)', (
    tester,
  ) async {
    final auth = AuthController();
    auth.debugSetUserData({'id': 'agent-1', 'name': 'Carlos Agent', 'email': 'carlos@compass.com'});

    await _pumpShell(tester, auth);

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Carlos Agent'));
      await tester.pumpAndSettle();
      expect(find.text('My Account'), findsOneWidget, reason: 'popup should open on cycle $i');

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('My Account'), findsNothing, reason: 'popup should close via Esc on cycle $i');
    }

    await tester.tap(find.text('Carlos Agent'));
    await tester.pumpAndSettle();
    expect(find.text('My Account'), findsOneWidget);

    await tester.tapAt(const Offset(600, 300));
    await tester.pumpAndSettle();

    expect(find.text('My Account'), findsNothing);
  });

  group('layout por largura (CPS-181)', () {
    AuthController agent() => AuthController()
      ..debugSetUserData({'id': 'agent-1', 'name': 'Carlos Agent', 'email': 'carlos@compass.com'});

    testWidgets('desktop (>= 1024) mostra a sidebar completa, sem tooltips de navegação', (tester) async {
      await _pumpShell(tester, agent(), size: const Size(1024, 800));

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Carlos Agent'), findsOneWidget);
      expect(find.byTooltip('Dashboard'), findsNothing);
    });

    testWidgets('tablet (600-1023) vira rail de ícones: sem rótulos, navegação por tooltip', (tester) async {
      final router = await _pumpShell(tester, agent(), size: const Size(1023, 800));

      expect(tester.takeException(), isNull);
      expect(find.text('Dashboard'), findsNothing);
      expect(find.text('Compass System'), findsNothing);
      expect(find.text('Carlos Agent'), findsNothing);
      expect(find.byTooltip('Dashboard'), findsOneWidget);

      await tester.tap(find.byTooltip('Users'));
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.toString(), '/c');
    });

    testWidgets('mobile (< 600) vira top bar acima do conteúdo, sem overflow em ~411 dp', (tester) async {
      final router = await _pumpShell(tester, agent(), size: const Size(411, 800));

      expect(tester.takeException(), isNull);
      expect(find.text('Compass System'), findsOneWidget);
      expect(find.text('Dashboard'), findsNothing);

      await tester.tap(find.byTooltip('Booking'));
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.toString(), '/b');
    });

    testWidgets('mobile em 360 dp cabe com os 4 destinos, sem overflow', (tester) async {
      await _pumpShell(tester, agent(), size: const Size(360, 800));

      expect(tester.takeException(), isNull);
      expect(find.byTooltip('Company'), findsOneWidget);
    });

    testWidgets('Empresa é o 4º item e abre a 4ª branch', (tester) async {
      final router = await _pumpShell(tester, agent());

      await tester.tap(find.text('Company'));
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.toString(), '/d');
    });

    testWidgets('o menu de conta abre pelo avatar no rail e na top bar', (tester) async {
      for (final width in [800.0, 411.0]) {
        final router = await _pumpShell(tester, agent(), size: Size(width, 800));
        await tester.tap(find.byTooltip('Carlos Agent'));
        await tester.pumpAndSettle();
        expect(find.text('My Account'), findsOneWidget, reason: 'largura $width');

        await tester.tap(find.text('My Account'));
        await tester.pumpAndSettle();
        expect(router.routerDelegate.currentConfiguration.uri.toString(), '/e');
      }
    });

    testWidgets('redimensionar troca sidebar, rail e top bar sem exceção', (tester) async {
      await _pumpShell(tester, agent());
      expect(find.text('Dashboard'), findsOneWidget);

      tester.view.physicalSize = const Size(800, 800);
      await tester.pumpAndSettle();
      expect(find.text('Dashboard'), findsNothing);
      expect(find.byTooltip('Dashboard'), findsOneWidget);

      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpAndSettle();
      expect(find.text('Compass System'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('recolher/ocultar o menu (CPS-200)', () {
    AuthController agent() => AuthController()
      ..debugSetUserData({'id': 'agent-1', 'name': 'Carlos Agent', 'email': 'carlos@compass.com'});

    Future<void> tap(WidgetTester tester, String tooltip) async {
      await tester.tap(find.byTooltip(tooltip));
      await tester.pumpAndSettle();
    }

    double contentWidth(WidgetTester tester) => tester.getSize(find.byType(StatefulNavigationShell)).width;

    testWidgets('desktop cicla sidebar, rail e oculta; o conteúdo ocupa o espaço liberado', (tester) async {
      await _pumpShell(tester, agent());
      expect(find.text('Dashboard'), findsOneWidget);
      expect(contentWidth(tester), 1280 - 250 - 1);

      await tap(tester, 'Collapse menu');
      expect(find.text('Dashboard'), findsNothing);
      expect(find.byTooltip('Dashboard'), findsOneWidget);
      expect(contentWidth(tester), 1280 - 72 - 1);

      await tap(tester, 'Hide menu');
      expect(find.byTooltip('Dashboard'), findsNothing);
      expect(find.byTooltip('Show menu'), findsOneWidget);
      expect(contentWidth(tester), 1280);

      await tap(tester, 'Show menu');
      expect(find.text('Dashboard'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tablet alterna rail e oculta, sem estado "expandida"', (tester) async {
      await _pumpShell(tester, agent(), size: const Size(800, 800));
      expect(find.byTooltip('Collapse menu'), findsNothing);

      await tap(tester, 'Hide menu');
      expect(find.byTooltip('Dashboard'), findsNothing);
      expect(contentWidth(tester), 800);

      await tap(tester, 'Show menu');
      expect(find.byTooltip('Dashboard'), findsOneWidget);
      expect(find.text('Dashboard'), findsNothing);
    });

    testWidgets('mobile esconde a top bar e o botão flutuante a traz de volta', (tester) async {
      await _pumpShell(tester, agent(), size: const Size(411, 800));
      expect(find.text('Compass System'), findsOneWidget);

      await tap(tester, 'Hide menu');
      expect(find.text('Compass System'), findsNothing);
      expect(find.byTooltip('Booking'), findsNothing);

      await tap(tester, 'Show menu');
      expect(find.text('Compass System'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('redimensionar preserva o estado de cada breakpoint', (tester) async {
      await _pumpShell(tester, agent());
      await tap(tester, 'Collapse menu'); // desktop: recolhida
      await tap(tester, 'Hide menu'); // desktop: oculta

      tester.view.physicalSize = const Size(800, 800);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Dashboard'), findsOneWidget, reason: 'tablet continua em rail');

      tester.view.physicalSize = const Size(1280, 800);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Show menu'), findsOneWidget, reason: 'desktop continua oculto');
      expect(tester.takeException(), isNull);
    });
  });
}
