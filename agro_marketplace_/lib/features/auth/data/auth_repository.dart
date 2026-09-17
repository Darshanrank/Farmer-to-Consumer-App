import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/services/firebase_service.dart';

part 'auth_repository.g.dart';

/// Repository for handling Firebase Authentication operations.
class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository(this._auth);

  /// Stream of Firebase Auth user changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Gets the current Firebase user synchronously.
  User? get currentUser => _auth.currentUser;

  /// Signs in a user with email and password.
  Future<Result<User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return Result.guard(() async {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw AuthenticationException(
          message: 'Login failed. User data is missing.',
        );
      }
      return credential.user!;
    });
  }

  /// Registers a new user with email and password.
  Future<Result<User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return Result.guard(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw AuthenticationException(
          message: 'Registration failed. User data is missing.',
        );
      }
      return credential.user!;
    });
  }

  /// Sends an email verification link to the current user.
  Future<Result<void>> sendEmailVerification() async {
    return Result.guard(() async {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          message: 'No user is currently signed in.',
        );
      }
      await user.sendEmailVerification();
    });
  }

  /// Reloads the current user to get the latest status (e.g. email verification).
  Future<Result<void>> reloadUser() async {
    return Result.guard(() async {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          message: 'No user is currently signed in.',
        );
      }
      await user.reload();
    });
  }

  /// Sends a password reset email.
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    return Result.guard(() async {
      await _auth.sendPasswordResetEmail(email: email);
    });
  }

  /// Signs out the current user.
  Future<Result<void>> signOut() async {
    return Result.guard(() async {
      await _auth.signOut();
    });
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(firebaseServiceProvider).auth);
}
