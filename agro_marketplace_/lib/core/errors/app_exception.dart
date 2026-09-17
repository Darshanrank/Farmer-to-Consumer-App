/// Centralized exception hierarchy for the application.
///
/// All application-level exceptions extend [AppException].
/// Firebase errors are mapped to these via [FirebaseErrorMapper].
/// UI/error handlers consume these to show safe, user-facing messages.
sealed class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException($code): $message';
}

/// Network connectivity issues.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Please check your internet connection.',
    super.code = 'network_error',
    super.originalError,
    super.stackTrace,
  });
}

/// Firebase Authentication failures.
class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    super.code = 'auth_error',
    super.originalError,
    super.stackTrace,
  });
}

/// Authorization / permission failures.
class AuthorizationException extends AppException {
  const AuthorizationException({
    super.message = 'You do not have permission to perform this action.',
    super.code = 'authorization_error',
    super.originalError,
    super.stackTrace,
  });
}

/// Input validation failures.
class ValidationException extends AppException {
  final Map<String, String> fieldErrors;

  const ValidationException({
    required super.message,
    this.fieldErrors = const {},
    super.code = 'validation_error',
    super.originalError,
    super.stackTrace,
  });
}

/// Business rule violations (e.g., seller not active, order already cancelled).
class BusinessRuleException extends AppException {
  const BusinessRuleException({
    required super.message,
    super.code = 'business_rule_error',
    super.originalError,
    super.stackTrace,
  });
}

/// Requested resource not found.
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.code = 'not_found',
    super.originalError,
    super.stackTrace,
  });
}

/// Conflict (e.g., duplicate entry, concurrent modification).
class ConflictException extends AppException {
  const ConflictException({
    super.message = 'A conflict occurred. Please try again.',
    super.code = 'conflict',
    super.originalError,
    super.stackTrace,
  });
}

/// Firebase-specific errors (Firestore, Storage, etc.) not covered above.
class FirebaseServiceException extends AppException {
  const FirebaseServiceException({
    required super.message,
    super.code = 'firebase_error',
    super.originalError,
    super.stackTrace,
  });
}

/// Represents an operation that was explicitly cancelled.
class AppCancelledException extends AppException {
  const AppCancelledException({
    super.message = 'Operation was cancelled.',
    super.code = 'cancelled',
    super.originalError,
    super.stackTrace,
  });
}

/// Request/operation timed out.
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'The operation timed out. Please try again.',
    super.code = 'timeout',
    super.originalError,
    super.stackTrace,
  });
}

/// Cloud Function or server-side errors.
class ServerException extends AppException {
  const ServerException({
    super.message = 'A server error occurred. Please try again later.',
    super.code = 'server_error',
    super.originalError,
    super.stackTrace,
  });
}

/// Unknown / unexpected errors — catch-all.
class UnknownException extends AppException {
  const UnknownException({
    super.message = 'An unexpected error occurred.',
    super.code = 'unknown_error',
    super.originalError,
    super.stackTrace,
  });
}
