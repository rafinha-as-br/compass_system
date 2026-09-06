import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/app/controllers/settings_controller.dart';
import 'package:routecraft_app/app/global_controllers/auth_controller.dart';
import 'package:routecraft_app/features/account/presentation/controllers/account_controller.dart';
import 'package:routecraft_app/features/account/presentation/pages/account_page.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

Widget _wrap(AccountController controller, {AuthController? authController}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsController>(create: (_) => SettingsController()),
      ChangeNotifierProvider<AuthController>.value(
        value: authController ?? AuthController(checkAuthenticated: () async => true),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: AccountPage(controller: controller),
    ),
  );
}

void main() {
  testWidgets('shows a loading spinner while fetching', (tester) async {
    await tester.pumpWidget(_wrap(AccountController.withState(const AccountState())));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the authenticated client\'s name and email, not a fixed example', (tester) async {
    await tester.pumpWidget(_wrap(AccountController.withState(
      const AccountState(isLoading: false, clientName: 'Rafaela Souza', clientEmail: 'rafaela@email.com'),
    )));

    expect(find.text('Rafaela Souza'), findsOneWidget);
    expect(find.text('rafaela@email.com'), findsOneWidget);
    expect(find.text('RS'), findsOneWidget);
    expect(find.text('John Doe'), findsNothing);
  });

  testWidgets('shows the agent block only when an agent name is available', (tester) async {
    await tester.pumpWidget(_wrap(AccountController.withState(
      const AccountState(isLoading: false, clientName: 'Rafaela Souza', agentName: 'Marcos Cardoso'),
    )));

    expect(find.text('Marcos Cardoso'), findsOneWidget);
    expect(find.text('MC'), findsOneWidget);
  });

  testWidgets('hides the agent block when there is no agent yet', (tester) async {
    await tester.pumpWidget(_wrap(AccountController.withState(
      const AccountState(isLoading: false, clientName: 'Rafaela Souza'),
    )));

    expect(find.text('MY AGENT'), findsNothing);
  });

  testWidgets('logging out clears the session via AuthController', (tester) async {
    var loggedOut = false;
    final authController = AuthController(
      checkAuthenticated: () async => true,
      clearToken: () async => loggedOut = true,
    );

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(
      AccountController.withState(const AccountState(isLoading: false, clientName: 'Rafaela Souza')),
      authController: authController,
    ));

    await tester.tap(find.text('LOGOUT'));
    await tester.pumpAndSettle();

    expect(loggedOut, isTrue);
    expect(authController.isAuthenticated, isFalse);
  });

  testWidgets('tapping a menu item shows a coming-soon message instead of navigating anywhere broken', (tester) async {
    await tester.pumpWidget(_wrap(AccountController.withState(
      const AccountState(isLoading: false, clientName: 'Rafaela Souza'),
    )));

    await tester.tap(find.text('Personal data'));
    await tester.pump();

    expect(find.text('Coming soon.'), findsOneWidget);
  });
}
