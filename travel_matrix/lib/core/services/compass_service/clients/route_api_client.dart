// ─── MUDANÇA PARA INTEGRAÇÃO ───────────────────────────────────────────────
// O endpoint /routes NÃO EXISTE na API Java (compass-api).
// O RoutePlan é parte do objeto Travel e é gerenciado por /travels/{id}.
//
// O que mudou:
//   - updateRoute() agora chama PUT /travels/{travelId} em vez de /routes/{id}
//     O parâmetro routeId passado pelo CompassService é, na prática, o travelId.
//   - Os demais métodos (getAllRoutes, getRoute, createRoute, deleteRoute, getInterests)
//     foram mantidos mas apontam para endpoints inexistentes no backend atual.
//     Eles retornarão 404 até que a API Java implemente /routes.
// ──────────────────────────────────────────────────────────────────────────

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

  // MUDANÇA PARA INTEGRAÇÃO: redireciona para PUT /travels/{travelId}.
  // O backend não tem /routes — o RoutePlan é atualizado via Travel.
  // O parâmetro [routeId] corresponde ao travelId passado por CompassService.
  // O [routeData] deve conter os campos do objeto Travel (incluindo routePlan).
  Future<Map<String, dynamic>> updateRoute(String token, String routeId, Map<String, dynamic> routeData) async {
    return ApiClient().put(token, '/travels/$routeId', {}, {}, routeData);
  }

  Future<Map<String, dynamic>> deleteRoute(String token, String routeId) async {
    return ApiClient().delete(token, '/routes/$routeId', {}, {}, {});
  }

  Future<Map<String, dynamic>> getInterests(String token, String routeId) async {
    return ApiClient().get(token, '/routes/$routeId/interests', {}, {}, {});
  }




}