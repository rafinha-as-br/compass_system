
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/repository/route_repository.dart';

class CrudRoute {
  final RouteRepository repository;

  CrudRoute(this.repository);

  Future<Result<RoutePlan>> updateRoute(
    String travelId,
    RoutePlan routePlan,
  ) async {
    return await repository.updateRoute(travelId, routePlan);
  }
}
