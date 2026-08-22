import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/app/app_injector.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/features/auth/domain/auth_repository.dart';
import 'package:travel_matrix/features/auth/domain/entities/auth_session.dart';
import 'package:travel_matrix/features/auth/presentation/controllers/login_controller.dart';
import 'package:travel_matrix/features/auth/presentation/widgets/login_panel.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

/// Mocktail é usado aqui na fronteira de dependência real (o repositório),
/// não no ChangeNotifier em si — Provider precisa de um Listenable de
/// verdade para reagir a notifyListeners(), então o LoginController usado
/// no teste é real, só a rede por trás dele é substituída.
class _MockAuthRepository extends Mock implements AuthRepository {}

Widget _wrap(LoginController controller) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: controller),
      ChangeNotifierProvider(create: (_) => AuthController()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: LoginPanel()),
    ),
  );
}

void main() {
  late _MockAuthRepository repository;
  late LoginController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppInjector.init();
    repository = _MockAuthRepository();
    controller = LoginController(repository: repository);
  });

  testWidgets('valida os campos obrigatórios sem chamar o repositório', (tester) async {
    await tester.pumpWidget(_wrap(controller));

    await tester.tap(find.text('LOGIN AS AGENT'));
    await tester.pump();

    expect(find.text('Enter email'), findsOneWidget);
    expect(find.text('Enter password'), findsOneWidget);
    verifyNever(() => repository.login(any(), any()));
  });

  testWidgets('exibe a mensagem de erro em credenciais inválidas, sem travar o formulário',
      (tester) async {
    when(() => repository.login(any(), any()))
        .thenThrow(StateError('Invalid credentials. Please try again.'));

    await tester.pumpWidget(_wrap(controller));

    await tester.enterText(find.byType(TextFormField).first, 'agente@compass.com');
    await tester.enterText(find.byType(TextFormField).last, 'senha-errada');
    await tester.tap(find.text('LOGIN AS AGENT'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid credentials. Please try again.'), findsOneWidget);

    // Regressão do bug de copyWith no formKey: depois de uma atualização de
    // estado (erro), o formulário continua validável — antes da correção,
    // o Form recebia uma GlobalKey nova a cada rebuild.
    await tester.enterText(find.byType(TextFormField).first, 'agente@compass.com');
    await tester.enterText(find.byType(TextFormField).last, 'senha123');
    await tester.tap(find.text('LOGIN AS AGENT'));
    await tester.pump();

    verify(() => repository.login('agente@compass.com', 'senha123')).called(1);
  });

  testWidgets('faz login com sucesso quando o usuário é um agente', (tester) async {
    when(() => repository.login(any(), any())).thenAnswer(
      (_) async => const AuthSession(token: 'abc123', userType: 'AGENTE'),
    );

    await tester.pumpWidget(_wrap(controller));

    await tester.enterText(find.byType(TextFormField).first, 'agente@compass.com');
    await tester.enterText(find.byType(TextFormField).last, 'senha123');
    await tester.tap(find.text('LOGIN AS AGENT'));
    await tester.pumpAndSettle();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.errorMessage, isNull);
  });
}
