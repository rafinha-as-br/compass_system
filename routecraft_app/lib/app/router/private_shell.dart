import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/app/router/private_shell_scaffold.dart';
import 'package:routecraft_app/features/account/presentation/pages/account_page.dart';
import 'package:routecraft_app/features/edit_route/presentation/pages/edit_route_page.dart';
import 'package:routecraft_app/features/home/presentation/pages/home_page.dart';
import 'package:routecraft_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:routecraft_app/features/itinerary_hub/presentation/pages/itinerary_hub_page.dart';
import 'package:routecraft_app/features/itinerary_timeline/presentation/pages/itinerary_timeline_page.dart';
import 'package:routecraft_app/features/itinerary_today/presentation/pages/itinerary_today_page.dart';
import 'package:routecraft_app/features/route_creation/presentation/pages/route_creation_page.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';

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
            routes: [
              GoRoute(
                path: AppRoutes.editRoute,
                builder: _editRouteBuilder,
              ),
              GoRoute(
                path: AppRoutes.itineraryTimeline,
                builder: _itineraryTimelineBuilder,
              ),
            ],
          ),
        ],
      ),
    ]),

    // Branch 1: Roteiro
    StatefulShellBranch(routes: [
      GoRoute(
        path: AppRoutes.itinerary,
        builder: (context, state) => const ItineraryHubPage(travel: null),
        routes: [
          GoRoute(
            path: AppRoutes.followTravel,
            builder: _followTravelBuilder,
            routes: [
              GoRoute(
                path: AppRoutes.editRoute,
                builder: _editRouteBuilder,
              ),
              GoRoute(
                path: AppRoutes.itineraryTimeline,
                builder: _itineraryTimelineBuilder,
              ),
            ],
          ),
        ],
      ),
    ]),

    // Branch 2: Conta
    StatefulShellBranch(routes: [
      GoRoute(
        path: AppRoutes.account,
        builder: (context, state) => const AccountPage(),
        routes: [
          GoRoute(
            path: AppRoutes.notifications,
            builder: (context, state) => const NotificationsPage(),
          ),
        ],
      ),
    ]),
  ],
);

Widget _followTravelBuilder(BuildContext context, GoRouterState state) {
  return ItineraryTodayPage(travel: state.extra as Travel?);
}

Widget _editRouteBuilder(BuildContext context, GoRouterState state) {
  return EditRoutePage(travel: state.extra as Travel);
}

Widget _itineraryTimelineBuilder(BuildContext context, GoRouterState state) {
  return ItineraryTimelinePage(travel: state.extra as Travel?);
}
