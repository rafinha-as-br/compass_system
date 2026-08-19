import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/features/auth/data/models/auth_session_dto.dart';

void main() {
  group('AuthSessionDto', () {
    test('fromJson maps token/userType/email', () {
      final dto = AuthSessionDto.fromJson({
        'token': 'abc123',
        'userId': '1',
        'name': 'John',
        'email': 'john@example.com',
        'userType': 'CLIENTE',
      });

      expect(dto.token, 'abc123');
      expect(dto.userType, 'CLIENTE');
      expect(dto.email, 'john@example.com');
    });

    test('toDomain preserves all fields', () {
      const dto = AuthSessionDto(
        token: 'abc123',
        userType: 'AGENTE',
        email: 'agent@example.com',
      );

      final session = dto.toDomain();

      expect(session.token, 'abc123');
      expect(session.userType, 'AGENTE');
      expect(session.email, 'agent@example.com');
    });
  });
}
