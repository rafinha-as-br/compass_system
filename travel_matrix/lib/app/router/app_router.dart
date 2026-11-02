import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/app/router/private_shell.dart';
import 'package:travel_matrix/app/router/public_shell.dart';
import 'package:travel_matrix/features/account/presentation/pages/change_password_page.dart';
import 'package:travel_matrix/features/auth/presentation/pages/connection_error_page.dart';
import 'package:travel_matrix/features/notifications/presentation/pages/notifications_page.dart';

class AppRouter {
  final AuthController _authController;

  AppRouter(this._authController);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.landing,
    refreshListenable: _authController,
    redirect: _redirect,
    routes: [
      publicShellRoute,
      privateShellRoute,
      // Not part of any sidebar branch (CPS-149's design keeps the 3 fixed
      // nav items as-is) — a full-screen route on top of the shell instead,
      // opened from the sidebar header's bell icon.
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.connectionError,
        builder: (context, state) => const ConnectionErrorPage(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    return redirectFor(
      isAuth: _authController.isAuthenticated,
      mustChangePassword: _authController.mustChangePassword,
      connectionError: _authController.hasConnectionError,
      location: state.matchedLocation,
    );
  }

  /// Pure so the guard can be tested without building a [GoRouterState].
  @visibleForTesting
  static String? redirectFor({
    required bool isAuth,
    required bool mustChangePassword,
    bool connectionError = false,
    required String location,
  }) {
    // Treat any route that is exactly '/' as public.
    final isOnPublic = location == AppRoutes.landing;
    final isOnChangePassword = location == AppRoutes.changePassword;
    final isOnConnectionError = location == AppRoutes.connectionError;

    if (!isAuth) return isOnPublic ? null : AppRoutes.landing;
    // A stored token whose agent data couldn't load (API unreachable) keeps
    // the session but shows no authenticated screen until a retry succeeds
    // (CPS-190).
    if (connectionError) return isOnConnectionError ? null : AppRoutes.connectionError;
    // A pending agent is locked to the change-password screen (CPS-197).
    if (mustChangePassword) return isOnChangePassword ? null : AppRoutes.changePassword;
    if (isOnPublic || isOnChangePassword || isOnConnectionError) return AppRoutes.dashboard;
    return null;
  }
}
