import 'package:travel_matrix/features/account/domain/entities/agent_profile.dart';

class AgentProfileDto {
  final String id;
  final String name;
  final String email;
  final String cpf;
  final String cnpj;
  final String phoneNumber;

  const AgentProfileDto({
    required this.id,
    required this.name,
    required this.email,
    required this.cpf,
    required this.cnpj,
    required this.phoneNumber,
  });

  factory AgentProfileDto.fromJson(Map<String, dynamic> json) {
    return AgentProfileDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      cpf: json['cpf']?.toString() ?? '',
      cnpj: json['cnpj']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? json['phone']?.toString() ?? '',
    );
  }

  AgentProfile toDomain() {
    return AgentProfile(
      id: id,
      name: name,
      email: email,
      cpf: cpf,
      cnpj: cnpj,
      phoneNumber: phoneNumber,
    );
  }
}
