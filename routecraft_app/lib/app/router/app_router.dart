import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:routecraft_app/app/global_controllers/auth_controller.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/app/router/private_shell.dart';
import 'package:routecraft_app/app/router/public_shell.dart';

class AppRouter {
  final AuthController _authController;

  AppRouter(this._authController);

  late final GoRouter router = GoRouter(
    // _redirect already runs against the initial location before the first
    // build, so it alone decides whether an authenticated session lands on
    // AppRoutes.home instead (matching travel_matrix's AppRouter).
    initialLocation: AppRoutes.login,
    refreshListenable: _authController,
    redirect: _redirect,
    routes: [
      publicShellRoute,
      privateShellRoute,
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final isAuth = _authController.isAuthenticated;
    final location = state.matchedLocation;
    final isOnPublic = location.startsWith(AppRoutes.login);

    if (!isAuth && !isOnPublic) return AppRoutes.login;
    if (isAuth && isOnPublic) return AppRoutes.home;
    return null;
  }
}
