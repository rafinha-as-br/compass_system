import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/app/router/private_shell_scaffold.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthStorageService.init();
  });

  testWidgets('renders the sidebar header (logo + app name) without throwing', (tester) async {
    final auth = AuthController();
    auth.debugSetUserData({'id': 'agent-1', 'name': 'Carlos Agent', 'email': 'carlos@compass.com'});

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
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
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

    expect(tester.takeException(), isNull);
    expect(find.byWidgetPredicate((w) => w is Image && (w.image as AssetImage).assetName == 'assets/images/logo_small.png'), findsOneWidget);
    expect(find.text('Travel Matrix'), findsOneWidget);
  });
}
