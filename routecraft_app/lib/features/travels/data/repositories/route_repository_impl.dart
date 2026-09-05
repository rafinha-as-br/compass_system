import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/api_exception.dart';
import 'package:routecraft_app/features/travels/data/datasources/route_data_source.dart';
import 'package:routecraft_app/features/travels/data/dtos/route_dto.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/repositories/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  final RouteDataSource _dataSource;

  RouteRepositoryImpl({RouteDataSource? dataSource}) : _dataSource = dataSource ?? RouteDataSource();

  @override
  Future<Result<RoutePlan>> updateRoute(String travelId, RoutePlan routePlan) async {
    try {
      final updated = await _dataSource.updateRoute(travelId, RoutePlanDTO.fromDomain(routePlan));
      return Result.success(updated.toDomain());
    } on ApiException catch (e) {
      return Result.failure(e.message, isConnectivityError: e.isConnectivityError);
    } catch (_) {
      return const Result.failure('Não foi possível atualizar a rota.', isConnectivityError: true);
    }
  }
}
