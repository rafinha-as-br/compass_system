import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/shared/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('retorna a mensagem quando o valor é nulo', () {
      expect(Validators.required(null, 'Campo obrigatório'), 'Campo obrigatório');
    });

    test('retorna a mensagem quando o valor é vazio', () {
      expect(Validators.required('', 'Campo obrigatório'), 'Campo obrigatório');
    });

    test('retorna null quando o valor está preenchido', () {
      expect(Validators.required('agente@routecraft.com', 'Campo obrigatório'), isNull);
    });
  });
}
