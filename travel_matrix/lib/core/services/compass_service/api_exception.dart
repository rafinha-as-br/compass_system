class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  factory ApiException.fromStatusCode(int? code, dynamic data) {
    switch (code) {
      case 400:
        return ApiException("Bad request", code);
      case 401:
        return ApiException("Unauthorized", code);
      case 404:
        return ApiException("Not found", code);
      case 500:
        return ApiException("Server error", code);
      default:
        return ApiException("Unknown error", code);
    }
  }
}