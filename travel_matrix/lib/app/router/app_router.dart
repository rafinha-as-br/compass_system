import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/app/router/private_shell.dart';
import 'package:travel_matrix/app/router/public_shell.dart';
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
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
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