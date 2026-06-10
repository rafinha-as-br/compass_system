
/// Represents a summary for a user's travel.
class TravelSummary{
  /// Travel id, cannot be null because all travels here must exist on the API
  final String backEndId;
  final String domainId;
  final String travelName;
  final String destination;
  final String status;
  final DateTime startDate;

  TravelSummary({
    required this.backEndId,
    required this.domainId,
    required this.travelName,
    required this.destination,
    required this.status,
    required this.startDate,
  });

}