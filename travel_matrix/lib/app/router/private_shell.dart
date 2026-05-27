import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';

import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/app/router/private_shell_scaffold.dart';
import 'package:travel_matrix/features/account/presentation/pages/account_page.dart';
import 'package:travel_matrix/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:travel_matrix/features/travels/presentation/pages/travels_dashboard_page.dart';
import 'package:travel_matrix/features/users/presentation/pages/users_dashboard_page.dart';

// Sub-route imports
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/pages/builds/travel_creation_page.dart';
import 'package:travel_matrix/features/travels/presentation/pages/views/travel_view_page.dart';
import 'package:travel_matrix/features/travels/presentation/pages/builds/route_creation_page.dart';
import 'package:travel_matrix/features/travels/presentation/pages/builds/itinerary_build_page.dart';
import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';
import 'package:travel_matrix/features/users/presentation/pages/create_user_page.dart';
import 'package:travel_matrix/features/users/presentation/pages/view_user_page.dart';
import 'package:travel_matrix/features/users/presentation/pages/edit_user_page.dart';

final privateShellRoute = StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return PrivateShellScaffold(navigationShell: navigationShell);
  },
  branches: [
    // Branch 0: Dashboard
    StatefulShellBranch(routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
    ]),
    
    // Branch 1: Booking / Travels
    StatefulShellBranch(routes: [
      GoRoute(
        path: AppRoutes.travels,
        builder: (context, state) => const TravelsDashboardPage(),
        routes: [
          GoRoute(
            path: AppRoutes.travelCreate,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final controller = extra?['controller'] as TravelsController?;
              if (controller == null) {
                 return const TravelsDashboardPage(); // Fallback for deep link
              }
              return ChangeNotifierProvider.value(
                value: controller,
                child: const TravelCreationPage(),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.travelView,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final travel = extra?['travel'] as TravelViewModel?;
              final controller = extra?['controller'] as TravelsController?;
              if (travel == null || controller == null) {
                return const TravelsDashboardPage(); // Fallback for deep link
              }
              return ChangeNotifierProvider.value(
                value: controller,
                child: TravelViewPage(travel: travel),
              );
            },
            routes: [
              GoRoute(
                path: AppRoutes.routeCreate,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  final travel = extra?['travel'] as TravelViewModel?;
                  if (travel == null) return const TravelsDashboardPage();
                  return RouteCreationPage(travel: travel);
                },
              ),
              GoRoute(
                path: AppRoutes.itineraryCreate,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  final travelId = extra?['travelId'] as String?;
                  final itineraryBuildModel = extra?['itineraryBuildModel'];
                  if (travelId == null || itineraryBuildModel == null) {
                    return const TravelsDashboardPage();
                  }
                  return ItineraryBuildPage(
                    travelId: travelId,
                    itineraryBuildModel: itineraryBuildModel,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ]),
    
    // Branch 2: Users
    StatefulShellBranch(routes: [
      GoRoute(
        path: AppRoutes.users,
        builder: (context, state) => const UsersDashboardPage(),
        routes: [
          GoRoute(
            path: AppRoutes.userCreate,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final controller = extra?['controller'] as UsersController?;
              if (controller == null) return const UsersDashboardPage();
              return ChangeNotifierProvider.value(
                value: controller,
                child: const CreateUserPage(),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.userView,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final user = extra?['user'] as Client?;
              final controller = extra?['controller'] as UsersController?;
              if (user == null || controller == null) return const UsersDashboardPage();
              return ChangeNotifierProvider.value(
                value: controller,
                child: ViewUserPage(user: user),
              );
            },
          ),
          GoRoute(
            path: '${AppRoutes.userView}/${AppRoutes.userEdit}',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final user = extra?['user'] as Client?;
              final controller = extra?['controller'] as UsersController?;
              if (user == null || controller == null) return const UsersDashboardPage();
              return ChangeNotifierProvider.value(
                value: controller,
                child: EditUserPage(user: user),
              );
            },
          ),
        ],
      ),
    ]),
    
    // Branch 3: Settings / Account
    StatefulShellBranch(routes: [
      GoRoute(
        path: AppRoutes.account,
        builder: (context, state) => const AccountPage(),
      ),
    ]),
  ],
);
