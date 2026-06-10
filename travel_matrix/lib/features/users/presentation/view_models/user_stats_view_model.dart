
import '../../domain/entities/user_stats.dart';

class UserStatsViewModel{
  final String totalTravels;
  final String uniqueDestinationsCount;

  UserStatsViewModel({
    required this.totalTravels,
    required this.uniqueDestinationsCount,
  });

  factory UserStatsViewModel.fromDomain(UserStats stats){
    return UserStatsViewModel(
      totalTravels: stats.totalTravels.toString(),
      uniqueDestinationsCount: stats.uniqueDestinationsCount.toString(),
    );
  }

  UserStats toDomain(){
    return UserStats(
      totalTravels: int.parse(totalTravels),
      uniqueDestinationsCount: int.parse(uniqueDestinationsCount),
    );
  }
}