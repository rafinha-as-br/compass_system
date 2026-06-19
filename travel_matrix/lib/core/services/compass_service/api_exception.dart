class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  factory ApiException.fromStatusCode(int? code, dynamic data) {
    // Try to extract the backend's error message
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
        return "Bad request";
      case 401:
        return "Unauthorized";
      case 403:
        return "Forbidden";
      case 404:
        return "Not found";
      case 500:
        return "Server error";
      default:
        return "Unknown error (code: $code)";
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
