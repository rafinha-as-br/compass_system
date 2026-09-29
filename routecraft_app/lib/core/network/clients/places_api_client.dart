import 'package:routecraft_app/core/network/api_endpoints.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/shared/models/place_suggestion.dart';

/// Thin wrapper over [HttpApiClient] for the places autocomplete facade
/// (`GET /places/autocomplete`, CPS-152). Provider unavailability comes
/// back as an [ApiException] like any other failed call — the caller
/// (`PlacesAutocompleteField`) is what degrades to free text.
class PlacesApiClient {
  final HttpApiClient _client;

  const PlacesApiClient(this._client);

  Future<List<PlaceSuggestion>> autocomplete(String token, String query) async {
    final response = await _client.get(token, ApiEndpoints.placesAutocomplete(query));
    final data = response['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(PlaceSuggestion.fromJson)
        .toList();
  }
}
