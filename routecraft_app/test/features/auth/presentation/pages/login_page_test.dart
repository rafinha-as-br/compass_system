import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/auth/domain/entities/auth_session.dart';
import 'package:routecraft_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:routecraft_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:routecraft_app/features/auth/presentation/controllers/login_controller.dart';
import 'package:routecraft_app/features/auth/presentation/pages/login_page.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

class _StubAuthRepository implements AuthRepository {
  _StubAuthRepository(this.result);

  final Result<AuthSession> result;
  String? capturedEmail;

  @override
  Future<Result<AuthSession>> login(String email, String password) async {
    capturedEmail = email;
    return result;
  }

  @override
  Future<Result<void>> requestPasswordReset(String email) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> resetPassword(String token, String newPassword) async {
    throw UnimplementedError();
  }
}

Widget _wrap(LoginController controller, {Locale? locale}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: LoginPage(controller: controller),
  );
}

void main() {
  testWidgets('renders every UI string from AppLocalizations (en)', (tester) async {
    final controller = LoginController(
      loginUseCase: LoginUseCase(_StubAuthRepository(const Result.failure(''))),
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
      loginUseCase: LoginUseCase(_StubAuthRepository(const Result.failure(''))),
      saveToken: (_) async {},
    );

    await tester.pumpWidget(_wrap(controller, locale: const Locale('pt')));

    expect(find.text('Login RouteCraft'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('ENTRAR'), findsOneWidget);
  });

  testWidgets('validates required fields without calling the use case', (tester) async {
    final repository = _StubAuthRepository(const Result.failure(''));
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
    final repository = _StubAuthRepository(const Result.failure('Invalid credentials.'));
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

  // The success path (saveToken called, navigation to GateAuth) is covered
  // at the controller level in login_controller_test.dart — reproducing it
  // here would require bootstrapping GateAuth's AuthService/secure storage,
  // unrelated to this page's rebranding/l10n scope.
}
