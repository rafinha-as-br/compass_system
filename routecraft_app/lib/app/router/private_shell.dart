import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/app/router/private_shell_scaffold.dart';
import 'package:routecraft_app/core/mock/mock_repository.dart';
import 'package:routecraft_app/features/account/presentation/pages/account_page.dart';
import 'package:routecraft_app/features/home/presentation/pages/follow_travel_page.dart';
import 'package:routecraft_app/features/home/presentation/pages/home_page.dart';
import 'package:routecraft_app/features/route_creation/presentation/pages/route_creation_page.dart';
import 'package:routecraft_app/features/visualization/presentation/pages/visualization_page.dart';

final privateShellRoute = StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return PrivateShellScaffold(navigationShell: navigationShell);
  },
  branches: [
    // Branch 0: Início
    StatefulShellBranch(routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: AppRoutes.createRoute,
            builder: (context, state) => const RouteCreationPage(),
          ),
          GoRoute(
            path: AppRoutes.followTravel,
            builder: _followTravelBuilder,
          ),
        ],
      ),
    ]),

    // Branch 1: Roteiro
    StatefulShellBranch(routes: [
      GoRoute(
        path: AppRoutes.itinerary,
        builder: (context, state) => const VisualizationPage(),
        routes: [
          GoRoute(
            path: AppRoutes.followTravel,
            builder: _followTravelBuilder,
          ),
        ],
      ),
    ]),

    // Branch 2: Conta
    StatefulShellBranch(routes: [
      GoRoute(
        path: AppRoutes.account,
        builder: (context, state) => const AccountPage(),
      ),
    ]),
  ],
);

Widget _followTravelBuilder(BuildContext context, GoRouterState state) {
  final travel = state.extra as Travel?;
  return FollowTravelPage(travel: travel);
}
