
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';

abstract class RouteRepository{

  /// Updates the route plan of an existing travel.
  ///
  /// The backend has no isolated route endpoint today — the route only
  /// travels embedded inside a [Travel] (see CPS-69) — so implementations
  /// are expected to compose this through the travel update path.
  Future<Result<RoutePlan>> updateRoute(String travelId, RoutePlan routePlan);

}
