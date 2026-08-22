/// Shared, reusable `TextFormField` validators — avoids reimplementing the
/// same one-liner in every form across the app.
abstract final class Validators {
  static String? required(String? value, String message) {
    return (value == null || value.isEmpty) ? message : null;
  }
}
