import 'app_exception.dart';
import 'firebase_error_mapper.dart';
import '../logging/app_logger.dart';

export 'firebase_error_mapper.dart';

/// Centralized error handler for the application.
///
/// Provides a single point for:
/// - Logging errors with structured context
/// - Mapping exceptions to user-facing messages
/// - Reporting errors to crash analytics (future)
///
/// Usage:
/// ```dart
/// try {
///   await someOperation();
/// } catch (e, st) {
///   ErrorHandler.handle(e, st, context: 'SellerRepository.createProfile');
/// }
/// ```
class ErrorHandler {
  const ErrorHandler._();

  /// Handles an error by logging it and optionally reporting to analytics.
  ///
  /// [error] The caught exception.
  /// [stackTrace] The stack trace from the catch clause.
  /// [context] A descriptive string indicating where the error occurred
  ///           (e.g., 'AuthRepository.signIn').
  /// [userId] Optional user ID for correlation.
  /// [operationId] Optional operation ID for tracing across systems.
  static AppException handle(
    dynamic error, [
    StackTrace? stackTrace,
    String? context,
    String? userId,
    String? operationId,
  ]) {
    final appException = _toAppException(error, stackTrace);

    AppLogger.error(
      appException.message,
      error: appException.originalError ?? appException,
      stackTrace: stackTrace,
      context: context,
      data: {
        if (appException.code != null) 'errorCode': appException.code,
        // ignore: use_null_aware_elements
        if (userId != null) 'userId': userId,
        // ignore: use_null_aware_elements
        if (operationId != null) 'operationId': operationId,
      },
    );

    // Future: Report to Firebase Crashlytics
    // _reportToCrashlytics(appException, stackTrace);
    
    return appException;
  }

  /// Converts any error into an [AppException].
  static AppException _toAppException(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;
    return FirebaseErrorMapper.mapException(error, stackTrace);
  }

  /// Extracts a safe, user-facing message from any error.
  ///
  /// Never exposes internal details, stack traces, or Firebase internals.
  static String getUserMessage(dynamic error) {
    if (error is AppException) return error.message;
    final mapped = _toAppException(error);
    return mapped.message;
  }

  /// Returns the error code for programmatic handling.
  static String? getErrorCode(dynamic error) {
    if (error is AppException) return error.code;
    final mapped = _toAppException(error);
    return mapped.code;
  }
}
