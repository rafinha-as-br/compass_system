import 'package:travel_matrix/core/services/compass_service/mock_api_client.dart';

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
    return MockApiClient().get(token, '/routes', {}, {}, {});
  }

  Future<Map<String, dynamic>> getRoute(String token, String routeId) async {
    return MockApiClient().get(token, '/routes/$routeId', {}, {}, {});
  }

  Future<Map<String, dynamic>> createRoute(String token, Map<String, dynamic> routeData) async {
    return MockApiClient().post(token, '/routes', {}, {}, routeData);
  }

  Future<Map<String, dynamic>> updateRoute(String token, String routeId, Map<String, dynamic> routeData) async {
    return MockApiClient().put(token, '/routes/$routeId', {}, {}, routeData);
  }

  Future<Map<String, dynamic>> deleteRoute(String token, String routeId) async {
    return MockApiClient().delete(token, '/routes/$routeId', {}, {}, {});
  }

  Future<Map<String, dynamic>> getInterests(String token, String routeId) async {
    return MockApiClient().get(token, '/routes/$routeId/interests', {}, {}, {});
  }




}