/// Latitude/longitude of a place — mirrors `compass-api`'s `Coordinate`.
class PlaceCoordinate {
  final double latitude;
  final double longitude;

  const PlaceCoordinate(this.latitude, this.longitude);

  @override
  bool operator ==(Object other) =>
      other is PlaceCoordinate &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// One suggestion returned by `GET /places/autocomplete` — always carries a
/// coordinate, unlike the free-text value the user may end up submitting.
class PlaceSuggestion {
  final String text;
  final PlaceCoordinate coordinate;

  const PlaceSuggestion({required this.text, required this.coordinate});

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      text: json['name'] as String,
      coordinate: PlaceCoordinate(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      ),
    );
  }
}

/// What [PlacesAutocompleteField] hands back to its caller: the text
/// currently in the field, and the coordinate — only non-null right after
/// the user picks a suggestion; typing again resets it to null.
class PlaceAutocompleteResult {
  final String text;
  final PlaceCoordinate? coordinate;

  const PlaceAutocompleteResult({required this.text, this.coordinate});
}
