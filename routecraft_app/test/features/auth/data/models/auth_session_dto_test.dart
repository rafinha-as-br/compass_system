import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/features/auth/data/models/auth_session_dto.dart';

void main() {
  group('AuthSessionDto', () {
    test('fromJson maps token/email', () {
      final dto = AuthSessionDto.fromJson({
        'token': 'abc123',
        'userId': '1',
        'name': 'John',
        'email': 'john@example.com',
      });

      expect(dto.token, 'abc123');
      expect(dto.email, 'john@example.com');
      expect(dto.name, 'John');
    });

    test('toDomain preserves all fields', () {
      const dto = AuthSessionDto(
        token: 'abc123',
        email: 'agent@example.com',
        name: 'Agent Name',
      );

      final session = dto.toDomain();

      expect(session.token, 'abc123');
      expect(session.email, 'agent@example.com');
      expect(session.name, 'Agent Name');
    });
  });
}
