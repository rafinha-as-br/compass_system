import 'package:routecraft_app/core/constants/api_fields.dart';
import 'package:routecraft_app/features/account/domain/entities/client_profile.dart';

class ClientProfileDTO {
  final String id;
  final String name;
  final String cpf;
  final String phoneNumber;
  final String email;
  final int? age;
  final String sex;

  const ClientProfileDTO({
    required this.id,
    required this.name,
    required this.cpf,
    required this.phoneNumber,
    required this.email,
    required this.age,
    required this.sex,
  });

  /// `GET /users/me` responds with the fields at the top level; `GET
  /// /users/{id}` and `PUT /users/{id}` wrap them under `data` — both shapes
  /// are handled by preferring `data` when present.
  factory ClientProfileDTO.fromJson(Map<String, dynamic> json) {
    final body = json[_dataKey] as Map<String, dynamic>? ?? json;
    return ClientProfileDTO(
      id: body[ClientProfileApiFields.id]?.toString() ?? '',
      name: body[ClientProfileApiFields.name]?.toString() ?? '',
      cpf: body[ClientProfileApiFields.cpf]?.toString() ?? '',
      phoneNumber: body[ClientProfileApiFields.phoneNumber]?.toString() ?? '',
      email: body[ClientProfileApiFields.email]?.toString() ?? '',
      age: (body[ClientProfileApiFields.age] as num?)?.toInt(),
      sex: body[ClientProfileApiFields.sex]?.toString() ?? '',
    );
  }

  static const _dataKey = 'data';

  /// Only the client-editable fields — `updateUser` patches whatever keys
  /// are present in the body, and `cpf`/`email` are read-only by design.
  Map<String, dynamic> toJson() {
    return {
      ClientProfileApiFields.name: name,
      ClientProfileApiFields.phoneNumber: phoneNumber,
      ClientProfileApiFields.age: age,
      ClientProfileApiFields.sex: sex,
    };
  }

  ClientProfile toDomain() {
    return ClientProfile(
      id: id,
      name: name,
      cpf: cpf,
      phoneNumber: phoneNumber,
      email: email,
      age: age,
      sex: sex,
    );
  }

  factory ClientProfileDTO.fromDomain(ClientProfile profile) {
    return ClientProfileDTO(
      id: profile.id,
      name: profile.name,
      cpf: profile.cpf,
      phoneNumber: profile.phoneNumber,
      email: profile.email,
      age: profile.age,
      sex: profile.sex,
    );
  }
}
