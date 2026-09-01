/// Single error contract shared across the auth data/domain layers.
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(String message, {bool isConnectivityError}) = Failure<T>;

  bool get isSuccess => this is Success<T>;

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String message) onFailure,
  }) {
    return switch (this) {
      Success<T>(data: final data) => onSuccess(data),
      Failure<T>(message: final message) => onFailure(message),
    };
  }
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final String message;

  /// True when [message] is an untranslated client-side network error — the
  /// UI should show a localized generic message instead.
  final bool isConnectivityError;

  const Failure(this.message, {this.isConnectivityError = false});
}
