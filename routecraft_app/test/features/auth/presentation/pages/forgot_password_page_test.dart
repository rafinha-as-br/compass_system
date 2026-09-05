import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/auth/domain/entities/auth_session.dart';
import 'package:routecraft_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:routecraft_app/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:routecraft_app/features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:routecraft_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:routecraft_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

class _StubAuthRepository implements AuthRepository {
  _StubAuthRepository(this.result);

  final Result<void> result;
  String? capturedEmail;

  @override
  Future<Result<AuthSession>> login(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> requestPasswordReset(String email) async {
    capturedEmail = email;
    return result;
  }

  @override
  Future<Result<void>> resetPassword(String token, String newPassword) async {
    throw UnimplementedError();
  }
}

Widget _wrap(ForgotPasswordController controller) {
  final router = GoRouter(
    initialLocation: AppRoutes.forgotPassword,
    routes: [
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => ForgotPasswordPage(controller: controller),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordPage(),
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
  testWidgets('valida o e-mail obrigatório sem chamar o repositório', (tester) async {
    final repository = _StubAuthRepository(const Result.success(null));
    final controller = ForgotPasswordController(
      requestPasswordResetUseCase: RequestPasswordResetUseCase(repository),
    );

    await tester.pumpWidget(_wrap(controller));

    await tester.tap(find.text('SEND CODE'));
    await tester.pump();

    expect(find.text('Enter email'), findsOneWidget);
    expect(repository.capturedEmail, isNull);
  });

  testWidgets(
    'envia o e-mail, mostra a confirmação genérica e navega para a tela de redefinição',
    (tester) async {
      final repository = _StubAuthRepository(const Result.success(null));
      final controller = ForgotPasswordController(
        requestPasswordResetUseCase: RequestPasswordResetUseCase(repository),
      );

      await tester.pumpWidget(_wrap(controller));

      await tester.enterText(find.byType(TextFormField), 'agente@routecraft.com');
      await tester.tap(find.text('SEND CODE'));
      await tester.pumpAndSettle();

      expect(repository.capturedEmail, 'agente@routecraft.com');
      expect(
        find.text(
          'If this email is registered, you will receive a code to reset your password.',
        ),
        findsOneWidget,
      );
      expect(find.text('Enter your code'), findsOneWidget);
    },
  );

  testWidgets('exibe a mensagem de erro quando o repositório falha', (tester) async {
    final repository = _StubAuthRepository(
      const Result.failure('Não foi possível completar a solicitação.'),
    );
    final controller = ForgotPasswordController(
      requestPasswordResetUseCase: RequestPasswordResetUseCase(repository),
    );

    await tester.pumpWidget(_wrap(controller));

    await tester.enterText(find.byType(TextFormField), 'agente@routecraft.com');
    await tester.tap(find.text('SEND CODE'));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível completar a solicitação.'), findsOneWidget);
  });
}
