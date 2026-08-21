
/// Represents a user's statistics.
class UserStats{
  final int totalTravels;
  /// Total number of unique destinations traveled by the user.
  final int uniqueDestinationsCount;

  UserStats({
    required this.totalTravels,
    required this.uniqueDestinationsCount,
  })  : assert(totalTravels >= 0, 'totalTravels cannot be negative'),
        assert(uniqueDestinationsCount >= 0,
            'uniqueDestinationsCount cannot be negative');

}