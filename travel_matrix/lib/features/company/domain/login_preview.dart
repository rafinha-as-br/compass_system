/// Estimativa client-side do login que o backend vai gerar para um agente
/// convidado: `localPart@domain`. Espelha a normalização do
/// `CompanyService.toLocalPart` do compass-api — sem acentos, minúsculo,
/// espaços/`-`/`_` viram `.`, só `[a-z0-9.]`, pontos colapsados e aparados.
///
/// É só um preview: a desambiguação de colisão (sufixo numérico) é decidida
/// no backend, então o login real pode receber um `2`, `3`… no final.
abstract final class LoginPreview {
  static const _accentMap = {
    'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c', 'ñ': 'n', 'ý': 'y', 'ÿ': 'y',
  };

  /// Local-part derivado do nome. Vazio quando o nome não gera nada útil.
  static String localPart(String name) {
    final buffer = StringBuffer();
    for (final rune in name.trim().toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_accentMap[char] ?? char);
    }
    return buffer
        .toString()
        .replaceAll(RegExp(r'[\s_-]+'), '.')
        .replaceAll(RegExp(r'[^a-z0-9.]'), '')
        .replaceAll(RegExp(r'\.{2,}'), '.')
        .replaceAll(RegExp(r'^\.|\.$'), '');
  }

  /// Login completo estimado, ou vazio se o nome não gera local-part.
  static String login(String name, String domain) {
    final part = localPart(name);
    return part.isEmpty ? '' : '$part@$domain';
  }
}
