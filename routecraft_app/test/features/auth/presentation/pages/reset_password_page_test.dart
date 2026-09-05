import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/auth/domain/entities/auth_session.dart';
import 'package:routecraft_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:routecraft_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:routecraft_app/features/auth/presentation/controllers/reset_password_controller.dart';
import 'package:routecraft_app/features/auth/presentation/pages/login_page.dart';
import 'package:routecraft_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

class _StubAuthRepository implements AuthRepository {
  _StubAuthRepository(this.result);

  final Result<void> result;
  String? capturedToken;
  String? capturedNewPassword;

  @override
  Future<Result<AuthSession>> login(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> requestPasswordReset(String email) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> resetPassword(String token, String newPassword) async {
    capturedToken = token;
    capturedNewPassword = newPassword;
    return result;
  }
}

Widget _wrap(ResetPasswordController controller) {
  final router = GoRouter(
    initialLocation: AppRoutes.resetPassword,
    routes: [
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => ResetPasswordPage(controller: controller),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

void main() {
  testWidgets('valida token e nova senha obrigatórios sem chamar o repositório', (tester) async {
    final repository = _StubAuthRepository(const Result.success(null));
    final controller = ResetPasswordController(
      resetPasswordUseCase: ResetPasswordUseCase(repository),
    );

    await tester.pumpWidget(_wrap(controller));

    await tester.tap(find.text('RESET PASSWORD'));
    await tester.pump();

    expect(find.text('Enter the code'), findsOneWidget);
    expect(find.text('Enter a new password'), findsOneWidget);
    expect(repository.capturedToken, isNull);
  });

  testWidgets('redefine a senha com sucesso e mostra a confirmação', (tester) async {
    final repository = _StubAuthRepository(const Result.success(null));
    final controller = ResetPasswordController(
      resetPasswordUseCase: ResetPasswordUseCase(repository),
    );

    await tester.pumpWidget(_wrap(controller));

    await tester.enterText(find.byType(TextFormField).first, 'token-123');
    await tester.enterText(find.byType(TextFormField).last, 'novaSenha456');
    await tester.tap(find.text('RESET PASSWORD'));
    await tester.pumpAndSettle();

    expect(repository.capturedToken, 'token-123');
    expect(repository.capturedNewPassword, 'novaSenha456');
    expect(
      find.text('Password reset successfully. You can now log in.'),
      findsOneWidget,
    );
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('exibe a mensagem de erro para token inválido/expirado', (tester) async {
    final repository = _StubAuthRepository(
      const Result.failure('Token inválido ou expirado.'),
    );
    final controller = ResetPasswordController(
      resetPasswordUseCase: ResetPasswordUseCase(repository),
    );

    await tester.pumpWidget(_wrap(controller));

    await tester.enterText(find.byType(TextFormField).first, 'token-invalido');
    await tester.enterText(find.byType(TextFormField).last, 'novaSenha456');
    await tester.tap(find.text('RESET PASSWORD'));
    await tester.pumpAndSettle();

    expect(find.text('Token inválido ou expirado.'), findsOneWidget);
  });
}
