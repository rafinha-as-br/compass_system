
/// Sentinel distinguishing "error not passed to copyWith" (keep the current
/// error) from "explicitly passed null" (clear it). A plain `??` fallback can't
/// tell the two apart, so a corrected field kept its stale error, the form
/// stayed invalid and the corrected value was never emitted to the editor.
const _unset = Object();

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
    Object? error = _unset,
    bool? isTouched,
  }){
    return FieldState(
      value: value ?? this.value,
      error: identical(error, _unset) ? this.error : error as String?,
      isTouched: isTouched ?? this.isTouched,
    );
  }
}
