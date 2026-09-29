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
import 'package:travel_matrix/app/router/private_shell_scaffold.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class _MockNotificationUseCases extends Mock implements NotificationUseCases {}

Future<GoRouter> _pumpShell(WidgetTester tester, AuthController auth) async {
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
        ],
      ),
    ],
  );

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: auth),
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
  });

  testWidgets('renders the sidebar header without a logo, with 3 nav items (no Configurações)', (tester) async {
    final auth = AuthController();
    auth.debugSetUserData({'id': 'agent-1', 'name': 'Carlos Agent', 'email': 'carlos@compass.com'});

    await _pumpShell(tester, auth);

    expect(tester.takeException(), isNull);
    expect(find.byType(Image), findsNothing);
    expect(find.text('Compass System'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Booking'), findsOneWidget);
    expect(find.text('Users'), findsOneWidget);
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

    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/d');
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
}
