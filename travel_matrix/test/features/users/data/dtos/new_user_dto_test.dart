import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/users/data/dtos/new_user_dto.dart';
import 'package:travel_matrix/features/users/domain/entities/new_user.dart';

NewUser _newUser({DateTime? birthDate}) => NewUser(
      name: 'New Client',
      cpf: '111.111.111-11',
      sex: 'F',
      phoneNumber: '11988887777',
      email: 'new@client.com',
      password: 'secret123',
      birthDate: birthDate,
    );

void main() {
  test('toJson always sends isActive true and includes birthDate only when set', () {
    final withoutBirthDate = NewUserDTO.fromDomain(_newUser()).toJson();
    expect(withoutBirthDate['isActive'], isTrue);
    expect(withoutBirthDate.containsKey('birthDate'), isFalse);
    expect(withoutBirthDate['password'], 'secret123');
    expect(withoutBirthDate.containsKey('id'), isFalse);
    expect(withoutBirthDate.containsKey('status'), isFalse);

    final withBirthDate =
        NewUserDTO.fromDomain(_newUser(birthDate: DateTime(2000, 5, 10))).toJson();
    expect(withBirthDate['birthDate'], DateTime(2000, 5, 10).toIso8601String());
  });
}
