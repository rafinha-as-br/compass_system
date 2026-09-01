import 'package:travel_matrix/features/users/domain/entities/new_user.dart';

/// Data transfer object for [NewUser] — write-only, used only by the create
/// endpoint. The API's create endpoint reads a flat [isActive] boolean
/// (always true for a brand-new user), not a nested status object.
class NewUserDTO {
  final String name;
  final String cpf;
  final String sex;
  final String phoneNumber;
  final String email;
  final String password;
  final DateTime? birthDate;

  NewUserDTO({
    required this.name,
    required this.cpf,
    required this.sex,
    required this.phoneNumber,
    required this.email,
    required this.password,
    this.birthDate,
  });

  factory NewUserDTO.fromDomain(NewUser user) {
    return NewUserDTO(
      name: user.name,
      cpf: user.cpf,
      sex: user.sex,
      phoneNumber: user.phoneNumber,
      email: user.email,
      password: user.password,
      birthDate: user.birthDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cpf': cpf,
      'sex': sex,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
      'isActive': true,
      if (birthDate != null) 'birthDate': birthDate!.toIso8601String(),
    };
  }
}
