import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/users/data/dtos/user_dto.dart';
import 'package:travel_matrix/features/users/data/dtos/user_stats_dto.dart';
import 'package:travel_matrix/features/users/data/dtos/user_status_dto.dart';

UserDTO _dto({String? password, DateTime? birthDate}) => UserDTO(
      id: 'user-1',
      name: 'Maria Silva',
      cpf: '000.000.000-00',
      sex: 'F',
      phoneNumber: '11999999999',
      status: UserClientStatusDto(status: ClientStatusDto(type: 'active')),
      email: 'maria@example.com',
      travels: const [],
      stats: UserStatsDTO(totalTravels: '0', uniqueDestinationsCount: '0'),
      password: password,
      birthDate: birthDate,
    );

void main() {
  test('toJson includes password/birthDate only when set, plus isActive derived from status', () {
    final withoutExtras = _dto().toJson();
    expect(withoutExtras.containsKey('password'), isFalse);
    expect(withoutExtras.containsKey('birthDate'), isFalse);
    expect(withoutExtras['isActive'], isTrue);

    final withExtras = _dto(password: 'secret123', birthDate: DateTime(2000, 5, 10)).toJson();
    expect(withExtras['password'], 'secret123');
    expect(withExtras['birthDate'], DateTime(2000, 5, 10).toIso8601String());
  });

  test('round-trips password/birthDate through fromDomain/toDomain', () {
    final dto = _dto(password: 'secret123', birthDate: DateTime(2000, 5, 10));
    final roundTripped = UserDTO.fromDomain(dto.toDomain());

    expect(roundTripped.password, 'secret123');
    expect(roundTripped.birthDate, DateTime(2000, 5, 10));
  });
}
