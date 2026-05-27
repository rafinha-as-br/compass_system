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
import 'package:travel_matrix/features/travels/presentation/models/build_models/itinerary_build_model.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/pages/builds/travel_creation_page.dart';
import 'package:travel_matrix/features/travels/presentation/pages/builds/route_creation_page.dart';
import 'package:travel_matrix/features/travels/presentation/pages/builds/itinerary_build_page.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/travel_view_wrapper.dart';
import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';
import 'package:travel_matrix/features/users/presentation/pages/create_user_page.dart';
import 'package:travel_matrix/features/users/presentation/pages/edit_user_page.dart';
import 'package:travel_matrix/features/users/presentation/widgets/user_view_wrapper.dart';

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
                return const TravelsDashboardPage();
              }
              return ChangeNotifierProvider<TravelsController>.value(
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
              final travelId = state.pathParameters['id']!;

              return TravelViewWrapper(
                travelId: travelId,
                initialTravel: travel,
                initialController: controller,
              );
            },
            routes: [
              GoRoute(
                path: AppRoutes.routeCreate,
                redirect: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  if (extra?['travel'] == null) {
                    final travelId = state.pathParameters['id']!;
                    return _travelPath(travelId);
                  }
                  return null;
                },
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>;
                  final travel = extra['travel'] as TravelViewModel;
                  return RouteCreationPage(travel: travel);
                },
              ),
              GoRoute(
                path: AppRoutes.itineraryCreate,
                redirect: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  if (extra?['travelId'] == null ||
                      extra?['itineraryBuildModel'] == null) {
                    final travelId = state.pathParameters['id']!;
                    return _travelPath(travelId);
                  }
                  return null;
                },
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>;
                  return ItineraryBuildPage(
                    travelId: extra['travelId'] as String,
                    itineraryBuildModel:
                        extra['itineraryBuildModel'] as ItineraryBuildModel,
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
              return ChangeNotifierProvider<UsersController>.value(
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
              final userId = state.pathParameters['id']!;

              return UserViewWrapper(
                userId: userId,
                initialUser: user,
                initialController: controller,
              );
            },
            routes: [
              GoRoute(
                path: AppRoutes.userEdit,
                redirect: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  if (extra?['user'] == null) {
                    final userId = state.pathParameters['id']!;
                    return _userPath(userId);
                  }
                  return null;
                },
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>;
                  final user = extra['user'] as Client;
                  final controller = extra['controller'] as UsersController?;

                  if (controller != null) {
                    return ChangeNotifierProvider<UsersController>.value(
                      value: controller,
                      child: EditUserPage(user: user),
                    );
                  }

                  return EditUserPage(user: user);
                },
              ),
            ],
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

String _travelPath(String travelId) => '${AppRoutes.travels}/$travelId';

String _userPath(String userId) => '${AppRoutes.users}/$userId';
