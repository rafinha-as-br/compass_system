
import 'package:travel_matrix/features/users/domain/user.dart';
import 'package:uuid/uuid.dart';

/// Data transfer object for [UserClient]
class UserDTO{
  /// Back end id, null in case of new entity
  final String? id;
  final String name;
  final String cpf;
  final String sex;
  final String phoneNumber;
  final String status;
  final String email;

  UserDTO({
    required this.id,
    required this.name,
    required this.cpf,
    required this.sex,
    required this.phoneNumber,
    required this.status,
    required this.email,
  });

  /// to domain mapper method
  UserClient toDomain(){
    return UserClient(
        backEndId: id,
        domainId: Uuid().v4(),
        name: name,
        cpf: cpf,
        sex: sex,
        phoneNumber: phoneNumber,
        status: status,
        email: email
    );
  }

  /// From domain mapper method
  factory UserDTO.fromDomain(UserClient user){
    return UserDTO(
      id: user.backEndId,
      name: user.name,
      cpf: user.cpf,
      sex: user.sex,
      phoneNumber: user.phoneNumber,
      status: user.status,
      email: user.email,
    );
  }

  /// To json method
  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'sex': sex,
      'phoneNumber': phoneNumber,
      'status': status,
      'email': email,
    };
  }

  /// From json factory method
  factory UserDTO.fromJson(Map<String, dynamic> json){
    return UserDTO(
      id: json['id'],
      name: json['name'],
      cpf: json['cpf'],
      sex: json['sex'],
      phoneNumber: json['phoneNumber'],
      status: json['status'],
      email: json['email'],
    );
  }


}