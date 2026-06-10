
import 'package:travel_matrix/features/users/domain/entities/user.dart';
import 'package:travel_matrix/features/users/presentation/view_models/client_status_view_model.dart';
import 'package:travel_matrix/features/users/presentation/view_models/travel_summary_view_model.dart';
import 'package:travel_matrix/features/users/presentation/view_models/user_stats_view_model.dart';

/// View model class for [UserClient]
class UserClientViewModel{
  final String? backEndId;
  final String localId;
  final String name;
  final String cpf;
  final String sex;
  final String phoneNumber;
  final UserClientStatusViewModel status;
  final String email;
  final List<TravelSummaryViewModel> travels;
  final UserStatsViewModel stats;

  UserClientViewModel({
    required this.backEndId,
    required this.localId,
    required this.name,
    required this.cpf,
    required this.sex,
    required this.phoneNumber,
    required this.status,
    required this.email,
    required this.travels,
    required this.stats,
  });

  /// From domain mapper method
  factory UserClientViewModel.fromDomain({required UserClient user}){
    return UserClientViewModel(
        backEndId: user.backEndId,
        localId: user.domainId,
        name: user.name,
        cpf: user.cpf,
        sex: user.sex,
        phoneNumber: user.phoneNumber,
        status: UserClientStatusViewModel.fromDomain(user.status),
        email: user.email,
        travels: user.travels.map((travel) => TravelSummaryViewModel.fromDomain(travel)).toList(),
        stats: UserStatsViewModel.fromDomain(user.stats),
    );
  }

  /// To domain mapper method
  UserClient toDomain(){
    return UserClient(
        backEndId: backEndId,
        domainId: localId,
        name: name,
        cpf: cpf,
        sex: sex,
        phoneNumber: phoneNumber,
        status: status.toDomain(),
        email: email,
        travels: travels.map((travel) => travel.toDomain()).toList(),
        stats: stats.toDomain(),
    );
  }

}