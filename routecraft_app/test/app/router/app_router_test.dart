import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/app/global_controllers/auth_controller.dart';
import 'package:routecraft_app/app/router/app_router.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/features/account/presentation/pages/account_page.dart';
import 'package:routecraft_app/features/auth/presentation/pages/login_page.dart';
import 'package:routecraft_app/features/home/presentation/pages/home_page.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

Widget _wrap(GoRouter router, AuthController auth) {
  return ChangeNotifierProvider<AuthController>.value(
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
  );
}

void main() {
  testWidgets('redirects a private route to login when there is no session', (tester) async {
    final auth = AuthController(checkAuthenticated: () async => false);
    await auth.refresh();
    final router = AppRouter(auth).router;

    await tester.pumpWidget(_wrap(router, auth));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    router.go(AppRoutes.account);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(AccountPage), findsNothing);
  });

  testWidgets('redirects away from login once the session is valid', (tester) async {
    final auth = AuthController(checkAuthenticated: () async => true);
    await auth.refresh();
    final router = AppRouter(auth).router;

    await tester.pumpWidget(_wrap(router, auth));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);

    router.go(AppRoutes.login);
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
  });
}
