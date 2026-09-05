import 'package:go_router/go_router.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:routecraft_app/features/auth/presentation/pages/login_page.dart';
import 'package:routecraft_app/features/auth/presentation/pages/reset_password_page.dart';

final publicShellRoute = GoRoute(
  path: AppRoutes.login,
  builder: (context, state) => const LoginPage(),
  routes: [
    GoRoute(
      path: AppRoutes.forgotPasswordSegment,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.resetPasswordSegment,
      builder: (context, state) => const ResetPasswordPage(),
    ),
  ],
);
