abstract final class CpfCnpjValidator {
  static bool isValidCpf(String input) {
    final digits = _onlyDigits(input);
    if (digits.length != 11 || _allDigitsEqual(digits)) return false;

    final numbers = digits.split('').map(int.parse).toList();

    final firstCheck = _checkDigit(numbers.sublist(0, 9), 10);
    if (firstCheck != numbers[9]) return false;

    final secondCheck = _checkDigit(numbers.sublist(0, 10), 11);
    return secondCheck == numbers[10];
  }

  static bool isValidCnpj(String input) {
    final digits = _onlyDigits(input);
    if (digits.length != 14 || _allDigitsEqual(digits)) return false;

    final numbers = digits.split('').map(int.parse).toList();

    const firstWeights = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    const secondWeights = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    final firstCheck = _weightedCheckDigit(numbers.sublist(0, 12), firstWeights);
    if (firstCheck != numbers[12]) return false;

    final secondCheck = _weightedCheckDigit(numbers.sublist(0, 13), secondWeights);
    return secondCheck == numbers[13];
  }

  static String _onlyDigits(String input) => input.replaceAll(RegExp(r'\D'), '');

  static bool _allDigitsEqual(String digits) => RegExp(r'^(\d)\1*$').hasMatch(digits);

  static int _checkDigit(List<int> numbers, int factorStart) {
    var sum = 0;
    var factor = factorStart;
    for (final number in numbers) {
      sum += number * factor;
      factor--;
    }
    final remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }

  static int _weightedCheckDigit(List<int> numbers, List<int> weights) {
    var sum = 0;
    for (var i = 0; i < numbers.length; i++) {
      sum += numbers[i] * weights[i];
    }
    final remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }
}
