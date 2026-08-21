import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/shared/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('retorna a mensagem quando o valor é nulo', () {
      expect(Validators.required(null, 'Campo obrigatório'), 'Campo obrigatório');
    });

    test('retorna a mensagem quando o valor é vazio', () {
      expect(Validators.required('', 'Campo obrigatório'), 'Campo obrigatório');
    });

    test('retorna null quando o valor está preenchido', () {
      expect(Validators.required('agente@matrix.com', 'Campo obrigatório'), isNull);
    });
  });
}
