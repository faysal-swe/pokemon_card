import '../error/failures.dart';

/// A lightweight, idiomatic Result type for handling success and failure cleanly.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(data: final d) => d,
        Error<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        Error<T>(failure: final f) => f,
      };

  R fold<R>({
    required R Function(Failure failure) onFailure,
    required R Function(T data) onSuccess,
  }) {
    return switch (this) {
      Success<T>(data: final d) => onSuccess(d),
      Error<T>(failure: final f) => onFailure(f),
    };
  }
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
