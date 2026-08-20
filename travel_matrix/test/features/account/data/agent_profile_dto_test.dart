import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/account/data/dtos/agent_profile_dto.dart';
import 'package:travel_matrix/features/account/domain/entities/agent_profile.dart';

void main() {
  group('AgentProfileDto', () {
    test('fromJson maps all fields, falling back to "phone" for phoneNumber', () {
      final dto = AgentProfileDto.fromJson({
        'id': '1',
        'name': 'Agent Smith',
        'email': 'agent@matrix.com',
        'cpf': '000.000.000-00',
        'cnpj': '00.000.000/0000-00',
        'phone': '11999999999',
      });

      expect(dto.id, '1');
      expect(dto.name, 'Agent Smith');
      expect(dto.email, 'agent@matrix.com');
      expect(dto.cpf, '000.000.000-00');
      expect(dto.cnpj, '00.000.000/0000-00');
      expect(dto.phoneNumber, '11999999999');
    });

    test('fromJson defaults missing fields to empty string', () {
      final dto = AgentProfileDto.fromJson(const {});

      expect(dto.id, '');
      expect(dto.name, '');
      expect(dto.email, '');
      expect(dto.cpf, '');
      expect(dto.cnpj, '');
      expect(dto.phoneNumber, '');
    });

    test('round-trips fromJson -> toDomain without losing data', () {
      final dto = AgentProfileDto.fromJson({
        'id': '42',
        'name': 'Trinity',
        'email': 'trinity@matrix.com',
        'cpf': '111.111.111-11',
        'cnpj': '11.111.111/1111-11',
        'phoneNumber': '11988887777',
      });

      final domain = dto.toDomain();

      expect(
        domain,
        const AgentProfile(
          id: '42',
          name: 'Trinity',
          email: 'trinity@matrix.com',
          cpf: '111.111.111-11',
          cnpj: '11.111.111/1111-11',
          phoneNumber: '11988887777',
        ),
      );
    });
  });
}
