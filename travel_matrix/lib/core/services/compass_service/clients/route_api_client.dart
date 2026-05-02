import 'package:travel_matrix/core/services/compass_service/api_client.dart';

class RouteApiClient{
  static RouteApiClient? _instance;

  RouteApiClient._();

  static Future<RouteApiClient> init() async{
    assert(_instance == null, 'RouteApiClient instance already initialized!');
    _instance ??= RouteApiClient._();
    return _instance!;
  }

  static RouteApiClient get instance{
    assert(_instance != null, 'RouteApiClient instance not initialized!');
    return _instance!;
  }

  Future<Map<String, dynamic>> getAllRoutes(String token) async{
    return ApiClient().get(token, '/routes', {}, {}, {});
  }

  Future<Map<String, dynamic>> getRoute(String token, String routeId) async {
    return ApiClient().get(token, '/routes/$routeId', {}, {}, {});
  }

  Future<Map<String, dynamic>> createRoute(String token, Map<String, dynamic> routeData) async {
    return ApiClient().post(token, '/routes', {}, {}, routeData);
  }

  Future<Map<String, dynamic>> updateRoute(String token, String routeId, Map<String, dynamic> routeData) async {
    return ApiClient().put(token, '/routes/$routeId', {}, {}, routeData);
  }

  Future<Map<String, dynamic>> deleteRoute(String token, String routeId) async {
    return ApiClient().delete(token, '/routes/$routeId', {}, {}, {});
  }

  Future<Map<String, dynamic>> getInterests(String token, String routeId) async {
    return ApiClient().get(token, '/routes/$routeId/interests', {}, {}, {});
  }




}