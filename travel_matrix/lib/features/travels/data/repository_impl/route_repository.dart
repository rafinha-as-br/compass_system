
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/repository/route_repository.dart';

import '../data_sources/route_data_source.dart';

class RouteRepositoryImpl implements RouteRepository{
  @override
  Future<Result<RoutePlan>> createRoute(Map<String, dynamic> data) {
    // TODO: implement createRoute
    throw UnimplementedError();
  }

  @override
  Future<Result<bool>> deleteRute(String id) {
    // TODO: implement deleteRute
    throw UnimplementedError();
  }

  @override
  Future<Result<RoutePlan>> getRoute(String id) async{
    try{
      final routeDto = await RouteDataSource().getRoute(id);
      final interestsListDto = await RouteDataSource().getInterests(routeDto.interestsList);
      return Result.success(
          routeDto.toDomain(interestsListDto.map((e) => e.toDomain()).toList())
      );
    } catch(e){
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<RoutePlan>> updateRoute(Map<String, dynamic> data) {
    // TODO: implement updateRoute
    throw UnimplementedError();
  }

}