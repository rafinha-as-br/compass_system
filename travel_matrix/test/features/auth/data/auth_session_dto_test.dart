import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/auth/data/dtos/auth_session_dto.dart';

void main() {
  group('AuthSessionDto', () {
    test('fromJson mapeia todos os campos corretamente', () {
      final dto = AuthSessionDto.fromJson(const {
        'token': 'token-123',
        'userType': 'AGENTE',
      });

      expect(dto.token, 'token-123');
      expect(dto.userType, 'AGENTE');
    });

    test(
      'toDomain converte para AuthSession preservando os dados (round-trip)',
      () {
        final dto = AuthSessionDto.fromJson(const {
          'token': 'token-123',
          'userType': 'AGENTE',
        });

        final session = dto.toDomain();

        expect(session.token, dto.token);
        expect(session.userType, dto.userType);
      },
    );

    test(
      'fromJson usa string vazia quando token/userType estão ausentes '
      '(comportamento atual — ver observação de code review sobre '
      'fallback silencioso em vez de falhar explicitamente)',
      () {
        final dto = AuthSessionDto.fromJson(const {});

        expect(dto.token, '');
        expect(dto.userType, '');
      },
    );
  });
}
