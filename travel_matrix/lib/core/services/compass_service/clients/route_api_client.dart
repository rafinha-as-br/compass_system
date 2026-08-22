import 'package:travel_matrix/core/services/compass_service/api_endpoints.dart';
import 'package:travel_matrix/core/services/compass_service/http_api_client.dart';

class RouteApiClient {
  static RouteApiClient? _instance;

  RouteApiClient._();

  static Future<RouteApiClient> init() async {
    assert(_instance == null, 'RouteApiClient instance already initialized!');
    _instance ??= RouteApiClient._();
    return _instance!;
  }

  static RouteApiClient get instance {
    assert(_instance != null, 'RouteApiClient instance not initialized!');
    return _instance!;
  }

  /// Routes are nested inside Travel objects in this API design.
  /// The route is updated via the Travel PUT endpoint.
  Future<Map<String, dynamic>> getAllRoutes(String token) async {
    return HttpApiClient.instance.get(token, '/routes');
  }

  Future<Map<String, dynamic>> getRoute(String token, String routeId) async {
    return HttpApiClient.instance.get(token, '/routes/$routeId');
  }

  Future<Map<String, dynamic>> createRoute(String token, Map<String, dynamic> routeData) async {
    return HttpApiClient.instance.post(token, '/routes', routeData);
  }

  /// Upserts the [RoutePlan] of a travel through the isolated route endpoint
  /// (`PUT /travels/{travelId}/route`), instead of the whole-Travel PUT.
  Future<Map<String, dynamic>> updateRoute(String token, String travelId, Map<String, dynamic> routeData) async {
    return HttpApiClient.instance.put(token, ApiEndpoints.travelRoute(travelId), routeData);
  }

  Future<Map<String, dynamic>> deleteRoute(String token, String routeId) async {
    return HttpApiClient.instance.delete(token, '/routes/$routeId');
  }

  Future<Map<String, dynamic>> getInterests(String token, String routeId) async {
    return HttpApiClient.instance.get(token, '/routes/$routeId/interests');
  }
}