import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/features/auth/domain/auth_repository.dart';
import 'package:travel_matrix/features/auth/domain/entities/auth_session.dart';
import 'package:travel_matrix/features/auth/presentation/controllers/login_controller.dart';
import 'package:travel_matrix/features/auth/presentation/widgets/forgot_password_panel.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.errorToThrow});

  final Object? errorToThrow;
  String? lastEmail;

  @override
  Future<AuthSession> login(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    lastEmail = email;
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    throw UnimplementedError();
  }
}

Widget _wrap(LoginController controller) {
  return ChangeNotifierProvider.value(
    value: controller,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: ForgotPasswordPanel()),
    ),
  );
}

void main() {
  testWidgets('valida o e-mail obrigatório sem chamar o repositório', (tester) async {
    final repository = _FakeAuthRepository();
    final controller = LoginController(repository: repository);

    await tester.pumpWidget(_wrap(controller));

    await tester.tap(find.text('SEND CODE'));
    await tester.pump();

    expect(find.text('Enter email'), findsOneWidget);
    expect(repository.lastEmail, isNull);
  });

  testWidgets(
    'envia o e-mail, mostra a confirmação genérica e navega para o painel de redefinição',
    (tester) async {
      final repository = _FakeAuthRepository();
      final controller = LoginController(repository: repository);

      await tester.pumpWidget(_wrap(controller));

      await tester.enterText(find.byType(TextFormField), 'agente@matrix.com');
      await tester.tap(find.text('SEND CODE'));
      await tester.pumpAndSettle();

      expect(repository.lastEmail, 'agente@matrix.com');
      expect(
        find.text(
          'If this email is registered, you will receive a code to reset your password.',
        ),
        findsOneWidget,
      );
      expect(controller.state.panel, AuthPanel.resetPassword);
    },
  );

  testWidgets('exibe a mensagem de erro quando o repositório falha', (tester) async {
    final repository = _FakeAuthRepository(
      errorToThrow: StateError('An error occurred. Please try again.'),
    );
    final controller = LoginController(repository: repository);

    await tester.pumpWidget(_wrap(controller));

    await tester.enterText(find.byType(TextFormField), 'agente@matrix.com');
    await tester.tap(find.text('SEND CODE'));
    await tester.pumpAndSettle();

    expect(find.text('An error occurred. Please try again.'), findsOneWidget);
  });
}
