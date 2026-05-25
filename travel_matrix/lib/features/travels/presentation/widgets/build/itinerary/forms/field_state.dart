
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
  }){
    return FieldState(
      value: value ?? this.value,
      error: error,
      isTouched: isTouched ?? this.isTouched,
    );
  }
}