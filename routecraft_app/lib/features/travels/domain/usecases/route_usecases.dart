import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/repositories/route_repository.dart';

class RouteUseCases {
  final RouteRepository repository;

  const RouteUseCases(this.repository);

  Future<Result<RoutePlan>> updateRoute(String travelId, RoutePlan routePlan) =>
      repository.updateRoute(travelId, routePlan);
}
