import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/features/auth/domain/auth_repository.dart';
import 'package:travel_matrix/features/auth/domain/entities/auth_session.dart';
import 'package:travel_matrix/features/auth/presentation/controllers/login_controller.dart';
import 'package:travel_matrix/features/auth/presentation/widgets/reset_password_panel.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.errorToThrow});

  final Object? errorToThrow;
  String? lastToken;
  String? lastNewPassword;

  @override
  Future<AuthSession> login(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    throw UnimplementedError();
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    lastToken = token;
    lastNewPassword = newPassword;
    if (errorToThrow != null) throw errorToThrow!;
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
      home: Scaffold(body: ResetPasswordPanel()),
    ),
  );
}

void main() {
  testWidgets('valida token e nova senha obrigatórios sem chamar o repositório', (tester) async {
    final repository = _FakeAuthRepository();
    final controller = LoginController(repository: repository);

    await tester.pumpWidget(_wrap(controller));

    await tester.tap(find.text('RESET PASSWORD'));
    await tester.pump();

    expect(find.text('Enter the code'), findsOneWidget);
    expect(find.text('Enter a new password'), findsOneWidget);
    expect(repository.lastToken, isNull);
  });

  testWidgets(
    'redefine a senha com sucesso, mostra a confirmação e volta para o login',
    (tester) async {
      final repository = _FakeAuthRepository();
      final controller = LoginController(repository: repository);

      await tester.pumpWidget(_wrap(controller));

      await tester.enterText(find.byType(TextFormField).first, 'token-123');
      await tester.enterText(find.byType(TextFormField).last, 'novaSenha456');
      await tester.tap(find.text('RESET PASSWORD'));
      await tester.pumpAndSettle();

      expect(repository.lastToken, 'token-123');
      expect(repository.lastNewPassword, 'novaSenha456');
      expect(
        find.text('Password reset successfully. You can now log in.'),
        findsOneWidget,
      );
      expect(controller.state.panel, AuthPanel.login);
    },
  );

  testWidgets('exibe a mensagem de erro para token inválido/expirado', (tester) async {
    final repository = _FakeAuthRepository(
      errorToThrow: StateError('Token inválido ou expirado.'),
    );
    final controller = LoginController(repository: repository);

    await tester.pumpWidget(_wrap(controller));

    await tester.enterText(find.byType(TextFormField).first, 'token-invalido');
    await tester.enterText(find.byType(TextFormField).last, 'novaSenha456');
    await tester.tap(find.text('RESET PASSWORD'));
    await tester.pumpAndSettle();

    expect(find.text('Token inválido ou expirado.'), findsOneWidget);
  });
}
