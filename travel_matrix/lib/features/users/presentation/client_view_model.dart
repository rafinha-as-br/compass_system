
import 'package:travel_matrix/features/users/domain/entities/user.dart';

/// View model class for [UserClient]
class UserClientViewModel{
  final String? domainId;
  final String localId;
  final String name;
  final String cpf;
  final String sex;
  final String phoneNumber;
  final String status;
  final String email;

  UserClientViewModel({
    this.domainId,
    required this.localId,
    required this.name,
    required this.cpf,
    required this.sex,
    required this.phoneNumber,
    required this.status,
    required this.email,
  });

  /// From domain mapper method


  /// To domain mapper method


}