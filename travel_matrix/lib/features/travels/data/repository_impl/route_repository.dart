import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/repository/route_repository.dart';

import '../data_sources/route_data_source.dart';

class RouteRepositoryImpl implements RouteRepository{
  @override
  Future<Result<RoutePlan>> createRoute(Map<String, dynamic> data) {
    throw UnimplementedError();
  }

  @override
  Future<Result<bool>> deleteRute(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Result<RoutePlan>> getRoute(String id) async{
    throw UnimplementedError("Route is now fetched along with the whole Travel via Travel API.");
  }

  @override
  Future<Result<RoutePlan>> updateRoute(Map<String, dynamic> data) {
    throw UnimplementedError();
  }

}