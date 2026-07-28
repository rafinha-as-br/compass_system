import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/core/validators/cpf_cnpj_validator.dart';

void main() {
  group('CpfCnpjValidator.isValidCpf', () {
    test('aceita CPF válido, com ou sem máscara', () {
      expect(CpfCnpjValidator.isValidCpf('111.444.777-35'), isTrue);
      expect(CpfCnpjValidator.isValidCpf('11144477735'), isTrue);
    });

    test('rejeita CPF com dígito verificador incorreto', () {
      expect(CpfCnpjValidator.isValidCpf('111.444.777-36'), isFalse);
    });

    test('rejeita CPF com todos os dígitos iguais', () {
      expect(CpfCnpjValidator.isValidCpf('111.111.111-11'), isFalse);
    });

    test('rejeita CPF com tamanho incorreto', () {
      expect(CpfCnpjValidator.isValidCpf('123456'), isFalse);
    });
  });

  group('CpfCnpjValidator.isValidCnpj', () {
    test('aceita CNPJ válido, com ou sem máscara', () {
      expect(CpfCnpjValidator.isValidCnpj('11.222.333/0001-81'), isTrue);
      expect(CpfCnpjValidator.isValidCnpj('11222333000181'), isTrue);
    });

    test('rejeita CNPJ com dígito verificador incorreto', () {
      expect(CpfCnpjValidator.isValidCnpj('11.222.333/0001-82'), isFalse);
    });

    test('rejeita CNPJ com todos os dígitos iguais', () {
      expect(CpfCnpjValidator.isValidCnpj('11.111.111/1111-11'), isFalse);
    });

    test('rejeita CNPJ com tamanho incorreto', () {
      expect(CpfCnpjValidator.isValidCnpj('123456'), isFalse);
    });
  });
}
