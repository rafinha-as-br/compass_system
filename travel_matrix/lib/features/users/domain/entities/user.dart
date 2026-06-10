
import 'package:travel_matrix/features/users/domain/entities/travel_summary.dart';
import 'package:travel_matrix/features/users/domain/entities/user_stats.dart';
import 'package:travel_matrix/features/users/domain/entities/user_status.dart';

class UserClient{
  final String? backEndId;
  final String domainId;
  final String name;
  final String cpf;
  final String sex;
  final String phoneNumber;
  final UserClientStatus status;
  final String email;
  final List<TravelSummary> travels;
  final UserStats stats;

  UserClient({
    required this.backEndId,
    required this.domainId,
    required this.name,
    required this.cpf,
    required this.sex,
    required this.phoneNumber,
    required this.status,
    required this.email,
    required this.travels,
    required this.stats,
  });


}