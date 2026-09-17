import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_exception.dart';

/// Maps Firebase SDK exceptions into the app's [AppException] hierarchy.
///
/// This ensures the UI and business logic never deal with raw Firebase errors.
/// All sensitive Firebase internals (paths, rule details) are stripped.
class FirebaseErrorMapper {
  const FirebaseErrorMapper._();

  /// Maps a [firebase_auth.FirebaseAuthException] to an [AppException].
  static AppException mapAuthException(firebase_auth.FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => const AuthenticationException(
          message: 'No account found with this email.',
          code: 'user_not_found',
        ),
      'wrong-password' => const AuthenticationException(
          message: 'Incorrect password. Please try again.',
          code: 'wrong_password',
        ),
      'invalid-credential' => const AuthenticationException(
          message: 'Invalid credentials. Please try again.',
          code: 'invalid_credential',
        ),
      'email-already-in-use' => const AuthenticationException(
          message: 'An account already exists with this email.',
          code: 'email_already_in_use',
        ),
      'weak-password' => const AuthenticationException(
          message: 'Password is too weak. Use at least 8 characters.',
          code: 'weak_password',
        ),
      'invalid-email' => const ValidationException(
          message: 'Please enter a valid email address.',
          code: 'invalid_email',
        ),
      'user-disabled' => const AuthenticationException(
          message: 'This account has been disabled. Contact support.',
          code: 'user_disabled',
        ),
      'too-many-requests' => const AuthenticationException(
          message: 'Too many attempts. Please try again later.',
          code: 'too_many_requests',
        ),
      'operation-not-allowed' => const AuthenticationException(
          message: 'This sign-in method is not enabled.',
          code: 'operation_not_allowed',
        ),
      'requires-recent-login' => const AuthenticationException(
          message: 'Please log in again to perform this action.',
          code: 'requires_recent_login',
        ),
      'network-request-failed' => const NetworkException(),
      _ => AuthenticationException(
          message: 'Authentication error. Please try again.',
          code: e.code,
          originalError: e,
        ),
    };
  }

  /// Maps a [FirebaseException] (Firestore, Storage, etc.) to an [AppException].
  static AppException mapFirebaseException(FirebaseException e) {
    return switch (e.code) {
      'permission-denied' => const AuthorizationException(),
      'not-found' => const NotFoundException(),
      'already-exists' => const ConflictException(
          message: 'This resource already exists.',
        ),
      'resource-exhausted' => const ServerException(
          message: 'Service is temporarily overloaded. Please try again.',
        ),
      'failed-precondition' => BusinessRuleException(
          message: e.message ?? 'Operation cannot be performed in the current state.',
        ),
      'aborted' => const ConflictException(
          message: 'Operation was aborted due to a conflict. Please retry.',
        ),
      'unavailable' => const NetworkException(
          message: 'Service is temporarily unavailable. Please try again.',
        ),
      'deadline-exceeded' => const TimeoutException(),
      'cancelled' => const AppCancelledException(),
      'unauthenticated' => const AuthenticationException(
          message: 'Please log in to continue.',
          code: 'unauthenticated',
        ),
      _ => FirebaseServiceException(
          message: 'An error occurred. Please try again.',
          code: e.code,
          originalError: e,
        ),
    };
  }

  /// Generic exception mapper — catches any exception and maps to [AppException].
  static AppException mapException(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;

    if (error is firebase_auth.FirebaseAuthException) {
      return mapAuthException(error);
    }

    if (error is FirebaseException) {
      return mapFirebaseException(error);
    }

    if (error is FormatException) {
      return ValidationException(
        message: 'Invalid data format.',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    return UnknownException(
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}
