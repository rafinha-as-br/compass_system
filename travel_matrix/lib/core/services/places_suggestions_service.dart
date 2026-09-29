import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/core/services/compass_service/clients/places_api_client.dart';
import 'package:travel_matrix/shared/models/place_suggestion.dart';

/// Resolves the stored auth token and calls the places autocomplete facade
/// (CPS-152) — the one place every itinerary form/page wires into
/// `PlacesAutocompleteField.fetchSuggestions`, instead of each repeating the
/// token lookup. No per-screen controller here (unlike RouteCraft) to hang
/// this on, since the transport forms are plain StatefulWidgets.
Future<List<PlaceSuggestion>> fetchPlaceSuggestions(String query) async {
  final token = await AuthStorageService.instance.getToken();
  return PlacesApiClient.instance.autocomplete(token ?? '', query);
}
