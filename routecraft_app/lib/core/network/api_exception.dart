class ApiException implements Exception {
  final String message;
  final int? statusCode;

  /// True when this came from a client-side network failure (timeout, no
  /// connection) rather than a message the backend actually returned — the
  /// UI should show a localized generic message instead of [message], which
  /// is not translated.
  final bool isConnectivityError;

  ApiException(this.message, [this.statusCode, this.isConnectivityError = false]);

  factory ApiException.fromStatusCode(int? code, dynamic data) {
    String message;
    if (data is Map<String, dynamic>) {
      message = data['message']?.toString() ??
                data['error']?.toString() ??
                _defaultMessage(code);
    } else if (data is String && data.isNotEmpty) {
      message = data;
    } else {
      message = _defaultMessage(code);
    }
    return ApiException(message, code);
  }

  static String _defaultMessage(int? code) {
    switch (code) {
      case 400:
        return "Requisição inválida";
      case 401:
        return "Não autorizado";
      case 403:
        return "Acesso negado";
      case 404:
        return "Não encontrado";
      case 500:
        return "Erro no servidor";
      default:
        return "Erro desconhecido (código: $code)";
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
