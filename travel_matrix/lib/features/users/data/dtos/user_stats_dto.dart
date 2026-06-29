
import '../../domain/entities/user_stats.dart';

class UserStatsDTO{
  final String totalTravels;
  final String uniqueDestinationsCount;

  UserStatsDTO({
    required this.totalTravels,
    required this.uniqueDestinationsCount,
  });


  factory UserStatsDTO.fromDomain(UserStats stats){
    return UserStatsDTO(
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

  factory UserStatsDTO.fromJson(Map<String, dynamic> json){
    return UserStatsDTO(
      totalTravels: json['totalTravels']?.toString() ?? '0',
      uniqueDestinationsCount: json['uniqueDestinationsCount']?.toString() ?? '0',
    );
  }

}