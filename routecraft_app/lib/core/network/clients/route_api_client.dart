import 'package:routecraft_app/core/network/api_endpoints.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';

/// Thin wrapper over [HttpApiClient] for the isolated route endpoint
/// (`PUT /travels/{travelId}/route`) — upserts only the route plan, without
/// touching the travel's itinerary/participants.
class RouteApiClient {
  final HttpApiClient _client;

  const RouteApiClient(this._client);

  Future<Map<String, dynamic>> updateRoute(String token, String travelId, Map<String, dynamic> routeData) {
    return _client.put(token, ApiEndpoints.travelRoute(travelId), routeData);
  }
}
