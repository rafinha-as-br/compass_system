import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/users/data/dtos/user_dto.dart';
import 'package:travel_matrix/features/users/data/dtos/user_stats_dto.dart';
import 'package:travel_matrix/features/users/data/dtos/user_status_dto.dart';

UserDTO _dto({String statusType = 'active'}) => UserDTO(
      id: 'user-1',
      name: 'Maria Silva',
      cpf: '000.000.000-00',
      sex: 'F',
      phoneNumber: '11999999999',
      status: UserClientStatusDto(status: ClientStatusDto(type: statusType)),
      email: 'maria@example.com',
      travels: const [],
      stats: UserStatsDTO(totalTravels: '0', uniqueDestinationsCount: '0'),
    );

void main() {
  test('toJson derives isActive from status and never leaks a password/birthDate key', () {
    final active = _dto().toJson();
    expect(active['isActive'], isTrue);
    expect(active.containsKey('password'), isFalse);
    expect(active.containsKey('birthDate'), isFalse);

    final inactive = _dto(statusType: 'inactive').toJson();
    expect(inactive['isActive'], isFalse);
  });

  test('round-trips the user fields through fromDomain/toDomain', () {
    final dto = _dto();
    final roundTripped = UserDTO.fromDomain(dto.toDomain());

    expect(roundTripped.id, 'user-1');
    expect(roundTripped.name, 'Maria Silva');
    expect(roundTripped.email, 'maria@example.com');
  });
}
