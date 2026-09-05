import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/app/global_controllers/auth_controller.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/auth/domain/entities/auth_session.dart';
import 'package:routecraft_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:routecraft_app/features/auth/presentation/controllers/login_controller.dart';
import 'package:routecraft_app/features/auth/presentation/pages/login_page.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

import '../../../../support/stub_auth_repository.dart';

Widget _wrap(LoginController controller, {Locale? locale, AuthController? authController}) {
  return ChangeNotifierProvider<AuthController>.value(
    value: authController ?? AuthController(checkAuthenticated: () async => false),
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: LoginPage(controller: controller),
    ),
  );
}

void main() {
  testWidgets('renders every UI string from AppLocalizations (en)', (tester) async {
    final controller = LoginController(
      loginUseCase: LoginUseCase(StubAuthRepository(const Result.failure(''))),
      saveToken: (_) async {},
    );

    await tester.pumpWidget(_wrap(controller, locale: const Locale('en')));

    expect(find.text('RouteCraft Login'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('renders every UI string from AppLocalizations (pt)', (tester) async {
    final controller = LoginController(
      loginUseCase: LoginUseCase(StubAuthRepository(const Result.failure(''))),
      saveToken: (_) async {},
    );

    await tester.pumpWidget(_wrap(controller, locale: const Locale('pt')));

    expect(find.text('Login RouteCraft'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('ENTRAR'), findsOneWidget);
  });

  testWidgets('validates required fields without calling the use case', (tester) async {
    final repository = StubAuthRepository(const Result.failure(''));
    final controller = LoginController(
      loginUseCase: LoginUseCase(repository),
      saveToken: (_) async {},
    );

    await tester.pumpWidget(_wrap(controller, locale: const Locale('en')));

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), '');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '');
    await tester.tap(find.text('LOGIN'));
    await tester.pump();

    expect(find.text('Enter email'), findsOneWidget);
    expect(find.text('Enter password'), findsOneWidget);
    expect(repository.capturedEmail, isNull);
  });

  testWidgets('submits valid credentials and surfaces a login failure message', (tester) async {
    final repository = StubAuthRepository(const Result.failure('Invalid credentials.'));
    final controller = LoginController(
      loginUseCase: LoginUseCase(repository),
      saveToken: (_) async {},
    );

    await tester.pumpWidget(_wrap(controller, locale: const Locale('en')));

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'agente@routecraft.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'secret123');
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(repository.capturedEmail, 'agente@routecraft.com');
    expect(find.text('Invalid credentials.'), findsOneWidget);
  });

  testWidgets('shows a localized generic message instead of the raw one on a connectivity failure', (tester) async {
    final repository = StubAuthRepository(
      const Result.failure('Não foi possível conectar ao servidor.', isConnectivityError: true),
    );
    final controller = LoginController(
      loginUseCase: LoginUseCase(repository),
      saveToken: (_) async {},
    );

    await tester.pumpWidget(_wrap(controller, locale: const Locale('en')));

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'a@b.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'secret123');
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(find.text('An error occurred during login.'), findsOneWidget);
    expect(find.text('Não foi possível conectar ao servidor.'), findsNothing);
  });

  testWidgets('refreshes AuthController on a successful login', (tester) async {
    final repository = StubAuthRepository(
      const Result.success(AuthSession(token: 'fake-token', email: 'agente@routecraft.com')),
    );
    final controller = LoginController(
      loginUseCase: LoginUseCase(repository),
      saveToken: (_) async {},
    );
    final authController = AuthController(checkAuthenticated: () async => true);

    await tester.pumpWidget(_wrap(controller, locale: const Locale('en'), authController: authController));

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'agente@routecraft.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'secret123');
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(authController.isAuthenticated, isTrue);
  });
}
