enum TravelStatus {
  routeCreated,
  itineraryReady,
  inProgress,
  completed,
  cancelled;

  static TravelStatus fromName(String? name) {
    return TravelStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => TravelStatus.routeCreated,
    );
  }
}
