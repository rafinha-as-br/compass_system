import 'package:routecraft_app/core/network/api_endpoints.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';

/// Thin wrapper over [HttpApiClient] for the `/travels` endpoints — split out
/// of a single monolithic service, one client per domain, matching
/// travel_matrix/lib/core/services/compass_service/clients/.
class TravelApiClient {
  final HttpApiClient _client;

  const TravelApiClient(this._client);

  Future<Map<String, dynamic>> getTravel(String token, String id) {
    return _client.get(token, ApiEndpoints.travelById(id));
  }

  /// The backend returns a raw JSON array; [HttpApiClient] wraps it as
  /// `{'data': [...]}` before this ever sees it.
  Future<List<Map<String, dynamic>>> getTravelsForClient(String token, String clientName) async {
    final result = await _client.get(token, ApiEndpoints.travelsByClient(clientName));
    final data = result['data'];
    if (data is! List) return const [];
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createTravel(String token, Map<String, dynamic> travelData) {
    return _client.post(token, ApiEndpoints.travels, travelData);
  }
}
