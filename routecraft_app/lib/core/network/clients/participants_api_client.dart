import 'package:routecraft_app/core/network/api_endpoints.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';

/// Thin wrapper over [HttpApiClient] for the isolated participants endpoint
/// (`PUT /travels/{travelId}/participants`) — upserts only the participants
/// list, without touching the travel's route/itinerary.
class ParticipantsApiClient {
  final HttpApiClient _client;

  const ParticipantsApiClient(this._client);

  Future<Map<String, dynamic>> updateParticipants(
    String token,
    String travelId,
    List<Map<String, dynamic>> participants,
  ) {
    return _client.put(token, ApiEndpoints.travelParticipants(travelId), participants);
  }
}
