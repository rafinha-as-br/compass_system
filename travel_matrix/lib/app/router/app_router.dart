import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/app/router/private_shell.dart';
import 'package:travel_matrix/app/router/public_shell.dart';

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
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final isAuth = _authController.isAuthenticated;
    final location = state.matchedLocation;
    
    // Treat any route that is exactly '/' as public.
    final isOnPublic = location == AppRoutes.landing;

    if (!isAuth && !isOnPublic) return AppRoutes.landing;
    if (isAuth && isOnPublic) return AppRoutes.dashboard;
    return null;
  }
}