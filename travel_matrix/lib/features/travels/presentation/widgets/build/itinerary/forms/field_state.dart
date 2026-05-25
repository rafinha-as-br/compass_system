
/// Contains the state of a field
class FieldState<T>{
  final T value;
  final String? error;
  final bool isTouched;

  const FieldState({
    required this.value,
    this.error,
    this.isTouched = false,
  });

  bool get isValid => error == null;

  FieldState<T> copyWith({
    T? value,
    String? error,
    bool? isTouched,
    bool clearError = false,
  }){
    return FieldState(
      value: value ?? this.value,
      error: clearError ? null : (error ?? this.error),
      isTouched: isTouched ?? this.isTouched,
    );
  }
}