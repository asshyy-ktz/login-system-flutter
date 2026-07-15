import '../errors/failures.dart';

/// A minimal `Either`-style result: [Success] holds a value, [Err] holds a
/// [Failure]. Keeps the domain layer dependency-free (no dartz).
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Err<T>;

  /// The value if successful, otherwise null.
  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        Err<T>() => null,
      };

  /// The failure if unsuccessful, otherwise null.
  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        Err<T>(:final failure) => failure,
      };

  R fold<R>(R Function(Failure failure) onFailure, R Function(T value) onSuccess) {
    return switch (this) {
      Success<T>(:final value) => onSuccess(value),
      Err<T>(:final failure) => onFailure(failure),
    };
  }
}

class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
