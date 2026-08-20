import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/network/api_exception.dart';

void main() {
  group('ApiException.fromStatusCode', () {
    test('extracts the message field when present', () {
      final exception = ApiException.fromStatusCode(400, {
        'message': 'E-mail ou senha incorretos.',
      });

      expect(exception.message, 'E-mail ou senha incorretos.');
      expect(exception.statusCode, 400);
    });

    test('falls back to the error field when message is absent', () {
      final exception = ApiException.fromStatusCode(409, {
        'error': 'E-mail já cadastrado.',
      });

      expect(exception.message, 'E-mail já cadastrado.');
    });

    test('uses the raw body when it is a non-empty string', () {
      final exception = ApiException.fromStatusCode(500, 'Falha interna');

      expect(exception.message, 'Falha interna');
    });

    test('falls back to a default message per status code when the body has neither field', () {
      expect(ApiException.fromStatusCode(401, <String, dynamic>{}).message, 'Não autorizado');
      expect(ApiException.fromStatusCode(404, null).message, 'Não encontrado');
      expect(ApiException.fromStatusCode(418, null).message, 'Erro desconhecido (código: 418)');
    });
  });
}
