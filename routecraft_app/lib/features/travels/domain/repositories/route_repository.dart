import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';

abstract interface class RouteRepository {
  /// Upserts the route plan of an existing travel through the isolated
  /// endpoint (`PUT /travels/{travelId}/route`), without touching its
  /// itinerary/participants.
  Future<Result<RoutePlan>> updateRoute(String travelId, RoutePlan routePlan);
}
