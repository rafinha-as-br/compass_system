import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/core/validators/email_validator.dart';

void main() {
  group('EmailValidator.isValid', () {
    test('aceita e-mails com formato válido', () {
      expect(EmailValidator.isValid('agente@compass.com'), isTrue);
      expect(EmailValidator.isValid('nome.sobrenome@empresa.com.br'), isTrue);
    });

    test('rejeita e-mail sem @', () {
      expect(EmailValidator.isValid('agentecompass.com'), isFalse);
    });

    test('rejeita e-mail sem domínio', () {
      expect(EmailValidator.isValid('agente@'), isFalse);
    });

    test('rejeita e-mail sem TLD', () {
      expect(EmailValidator.isValid('agente@compass'), isFalse);
    });

    test('rejeita string vazia', () {
      expect(EmailValidator.isValid(''), isFalse);
    });

    test('rejeita e-mail com espaços', () {
      expect(EmailValidator.isValid('agente @compass.com'), isFalse);
    });
  });
}
