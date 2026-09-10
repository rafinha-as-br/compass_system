import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/features/account/data/dtos/client_profile_dto.dart';
import 'package:routecraft_app/features/account/domain/entities/client_profile.dart';

void main() {
  group('ClientProfileDTO.fromJson', () {
    test('reads a flat body, as returned by GET /users/me', () {
      final dto = ClientProfileDTO.fromJson(const {
        'id': '1',
        'name': 'Maria Cliente',
        'cpf': '12345678900',
        'sex': 'F',
        'age': 30,
        'phoneNumber': '11999998888',
        'email': 'maria@email.com',
        'isActive': true,
      });

      expect(dto.id, '1');
      expect(dto.name, 'Maria Cliente');
      expect(dto.cpf, '12345678900');
      expect(dto.sex, 'F');
      expect(dto.age, 30);
      expect(dto.phoneNumber, '11999998888');
      expect(dto.email, 'maria@email.com');
    });

    test('reads a body wrapped under "data", as returned by GET/PUT /users/{id}', () {
      final dto = ClientProfileDTO.fromJson(const {
        'status': 'success',
        'data': {
          'id': '1',
          'name': 'Maria Cliente',
          'cpf': '12345678900',
          'sex': 'F',
          'age': 42,
          'phoneNumber': '11999998888',
          'email': 'maria@email.com',
        },
        'message': null,
      });

      expect(dto.id, '1');
      expect(dto.age, 42);
    });

    test('defaults age to null when the backend omits it', () {
      final dto = ClientProfileDTO.fromJson(const {
        'id': '1',
        'name': 'Maria Cliente',
        'cpf': '12345678900',
        'sex': 'F',
        'phoneNumber': '11999998888',
        'email': 'maria@email.com',
      });

      expect(dto.age, isNull);
    });
  });

  test('toJson only sends the client-editable fields', () {
    const dto = ClientProfileDTO(
      id: '1',
      name: 'Maria Cliente',
      cpf: '12345678900',
      phoneNumber: '11999998888',
      email: 'maria@email.com',
      age: 30,
      sex: 'F',
    );

    final json = dto.toJson();

    expect(json, {'name': 'Maria Cliente', 'phoneNumber': '11999998888', 'age': 30, 'sex': 'F'});
    expect(json.containsKey('cpf'), isFalse);
    expect(json.containsKey('email'), isFalse);
  });

  test('toDomain/fromDomain round-trip without losing data', () {
    const dto = ClientProfileDTO(
      id: '1',
      name: 'Maria Cliente',
      cpf: '12345678900',
      phoneNumber: '11999998888',
      email: 'maria@email.com',
      age: 30,
      sex: 'F',
    );

    final roundTripped = ClientProfileDTO.fromDomain(dto.toDomain());

    expect(roundTripped.id, dto.id);
    expect(roundTripped.name, dto.name);
    expect(roundTripped.cpf, dto.cpf);
    expect(roundTripped.phoneNumber, dto.phoneNumber);
    expect(roundTripped.email, dto.email);
    expect(roundTripped.age, dto.age);
    expect(roundTripped.sex, dto.sex);
  });

  test('ClientProfile.copyWith only overrides the given fields', () {
    const profile = ClientProfile(
      id: '1',
      name: 'Maria Cliente',
      cpf: '12345678900',
      phoneNumber: '11999998888',
      email: 'maria@email.com',
      age: 30,
      sex: 'F',
    );

    final updated = profile.copyWith(name: 'Maria Souza', age: 31);

    expect(updated.name, 'Maria Souza');
    expect(updated.age, 31);
    expect(updated.cpf, profile.cpf);
    expect(updated.email, profile.email);
    expect(updated.phoneNumber, profile.phoneNumber);
    expect(updated.sex, profile.sex);
  });
}
