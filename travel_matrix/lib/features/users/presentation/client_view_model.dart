
import 'package:travel_matrix/features/users/domain/user.dart';

/// View model class for [UserClient]
class UserClientViewModel{
  final String? backEndId;
  final String localId;
  final String name;
  final String cpf;
  final String sex;
  final String phoneNumber;
  final String status;
  final String email;

  UserClientViewModel({
    required this.backEndId,
    required this.localId,
    required this.name,
    required this.cpf,
    required this.sex,
    required this.phoneNumber,
    required this.status,
    required this.email,
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
        status: user.status,
        email: user.email
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
        status: status,
        email: email
    );
  }

}