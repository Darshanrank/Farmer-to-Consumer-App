import '../errors/app_exception.dart';
import '../errors/error_handler.dart';

/// A discriminated union representing success or failure.
///
/// Forces callers to handle both cases explicitly, eliminating
/// forgotten error handling. Used consistently across all repositories
/// and use cases.
///
/// Usage:
/// ```dart
/// final result = await authRepository.signIn(email, password);
/// switch (result) {
///   case Success(:final data):
///     // handle success
///     break;
///   case Failure(:final exception):
///     // handle failure
///     break;
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Wraps an async operation in a try-catch, mapping errors using [ErrorHandler].
  static Future<Result<T>> guard<T>(Future<T> Function() callback) async {
    try {
      final data = await callback();
      return Result.success(data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Result.failure(exception);
    }
  }

  /// Creates a successful result with [data].
  const factory Result.success(T data) = Success<T>;

  /// Creates a failure result with an [exception].
  const factory Result.failure(AppException exception) = Failure<T>;

  /// Whether this result is a success.
  bool get isSuccess => this is Success<T>;

  /// Whether this result is a failure.
  bool get isFailure => this is Failure<T>;

  /// Returns the data if success, or null if failure.
  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    Failure() => null,
  };

  /// Returns the exception if failure, or null if success.
  AppException? get exceptionOrNull => switch (this) {
    Success() => null,
    Failure(:final exception) => exception,
  };

  /// Maps the success data to a new type.
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
    Success(:final data) => Result.success(transform(data)),
    Failure(:final exception) => Result.failure(exception),
  };

  /// Chains another result-producing operation.
  Future<Result<R>> flatMap<R>(
    Future<Result<R>> Function(T data) transform,
  ) async => switch (this) {
    Success(:final data) => await transform(data),
    Failure(:final exception) => Result.failure(exception),
  };

  /// Executes [onSuccess] or [onFailure] based on the result.
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) => switch (this) {
    Success(:final data) => success(data),
    Failure(:final exception) => failure(exception),
  };
}

/// Represents a successful operation result.
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> && runtimeType == other.runtimeType && data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Represents a failed operation result.
class Failure<T> extends Result<T> {
  final AppException exception;
  const Failure(this.exception);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> && runtimeType == other.runtimeType && exception == other.exception;

  @override
  int get hashCode => exception.hashCode;

  @override
  String toString() => 'Failure(${exception.code}: ${exception.message})';
}
