import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/data/data_sources/route_data_source.dart';
import 'package:travel_matrix/features/travels/data/dtos/route_dto.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/repository/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  final RouteDataSource _dataSource;

  RouteRepositoryImpl({RouteDataSource? dataSource}) : _dataSource = dataSource ?? RouteDataSource();

  @override
  Future<Result<RoutePlan>> updateRoute(
    String travelId,
    RoutePlan routePlan,
  ) async {
    try {
      // Upserts through the isolated route endpoint (PUT /travels/{travelId}/route),
      // sending the complete RoutePlan — the backend only ever touches this
      // travel's route, never its participants/itinerary/events, so there is
      // no risk of clobbering unrelated data with a stale local copy.
      final result = await _dataSource.updateRoute(
        travelId,
        RoutePlanDTO.fromDomain(routePlan: routePlan),
      );
      return Result.success(result.toDomain());
    } catch (e) {
      return Result.failure('Failed to update route: $e');
    }
  }
}
