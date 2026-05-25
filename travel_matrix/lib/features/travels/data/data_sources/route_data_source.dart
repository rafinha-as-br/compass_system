
import 'package:travel_matrix/core/services/compass_service/clients/route_api_client.dart';
import 'package:travel_matrix/features/travels/data/dtos/route_dto.dart';
import '../../../../core/services/auth_service.dart';

class RouteDataSource{
  final _routeService = RouteApiClient.instance;
  final _authService = AuthService.instance;

  Future<RoutePlanDTO> getRoute(String id) async{
    final token = await _authService.getToken();
    final result = await _routeService.getRoute(token!, id);
    return RoutePlanDTO.fromJson(result);
  }

  Future<List<InterestPointDTO>> getInterests(List<String> ids) async {
    final token = await _authService.getToken();
    final result = await Future.wait(ids.map((id) => _routeService.getInterests(token!, id)));
    return result.map((e) => InterestPointDTO.fromJson(e)).toList();
  }

}


