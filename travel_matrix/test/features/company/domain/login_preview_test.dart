import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/company/domain/login_preview.dart';

/// Espelha `CompanyServiceTest` do compass-api: as regras precisam bater para
/// o preview não mentir para o usuário.
void main() {
  group('LoginPreview.localPart', () {
    test('removes accents, lowercases and turns spaces into dots', () {
      expect(LoginPreview.localPart('Ana Paula Ribeiro'), 'ana.paula.ribeiro');
      expect(LoginPreview.localPart('João César'), 'joao.cesar');
      expect(LoginPreview.localPart('  Maria   José  '), 'maria.jose');
    });

    test('drops characters outside [a-z0-9.] and treats - and _ as separators', () {
      expect(LoginPreview.localPart("Ana O'Connor"), 'ana.oconnor');
      expect(LoginPreview.localPart('Luiz-Silva'), 'luiz.silva');
      expect(LoginPreview.localPart('Agente #2'), 'agente.2');
    });

    test('collapses and trims dots', () {
      expect(LoginPreview.localPart('. Ana . Paula .'), 'ana.paula');
    });

    test('returns empty when nothing useful remains', () {
      expect(LoginPreview.localPart('   '), '');
      expect(LoginPreview.localPart('@#\$'), '');
    });
  });

  group('LoginPreview.login', () {
    test('appends the company domain', () {
      expect(
        LoginPreview.login('Ana Paula Ribeiro', 'aurora.com.br'),
        'ana.paula.ribeiro@aurora.com.br',
      );
    });

    test('is empty while the name produces no local-part', () {
      expect(LoginPreview.login('', 'aurora.com.br'), '');
      expect(LoginPreview.login('!!!', 'aurora.com.br'), '');
    });
  });
}
