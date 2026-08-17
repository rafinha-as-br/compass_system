abstract final class EmailValidator {
  static final RegExp _pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isValid(String input) => _pattern.hasMatch(input.trim());
}
