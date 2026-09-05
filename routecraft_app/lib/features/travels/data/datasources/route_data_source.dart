import 'package:routecraft_app/core/network/clients/route_api_client.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/features/travels/data/dtos/route_dto.dart';

class RouteDataSource {
  final RouteApiClient _client;
  final Future<String?> Function()? _getTokenOverride;

  RouteDataSource({RouteApiClient? client, Future<String?> Function()? getToken})
      : _client = client ?? RouteApiClient(HttpApiClient.instance),
        _getTokenOverride = getToken;

  Future<String> _token() async => await (_getTokenOverride ?? AuthService.instance.getToken)() ?? '';

  Future<RoutePlanDTO> updateRoute(String travelId, RoutePlanDTO route) async {
    final result = await _client.updateRoute(await _token(), travelId, route.toJson());
    return RoutePlanDTO.fromJson(result);
  }
}
