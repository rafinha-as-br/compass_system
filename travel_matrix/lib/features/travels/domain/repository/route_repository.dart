
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';

abstract class RouteRepository{

  /// get
  Future<Result<RoutePlan>> getRoute(String id);

  /// create
  Future<Result<RoutePlan>> createRoute(Map<String, dynamic> data);

  /// update
  Future<Result<RoutePlan>> updateRoute(Map<String, dynamic> data);

  /// delete
  Future<Result<bool>> deleteRute(String id);

}