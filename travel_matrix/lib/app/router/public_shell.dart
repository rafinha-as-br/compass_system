import 'package:go_router/go_router.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/features/auth/presentation/pages/landing_page.dart';

final publicShellRoute = GoRoute(
  path: AppRoutes.landing,
  builder: (context, state) => const LandingPage(),
);
