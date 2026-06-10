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
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      cpf: json['cpf'] as String? ?? '',
      cnpj: json['cnpj'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
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
