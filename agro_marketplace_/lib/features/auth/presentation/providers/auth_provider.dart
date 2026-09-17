import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/enums/auth_status.dart';
import '../../data/auth_repository.dart';
import '../../data/user_repository.dart';
import '../../../../core/logging/app_logger.dart';

part 'auth_provider.g.dart';

/// Exposes the raw Firebase Auth user stream.
@riverpod
Stream<firebase_auth.User?> authUser(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

/// Exposes the Firestore `AppUser` profile for the currently authenticated user.
@riverpod
Stream<AppUser?> appUser(Ref ref) {
  final authUser = ref.watch(authUserProvider).value;
  if (authUser == null) {
    return Stream.value(null);
  }
  return ref.watch(userRepositoryProvider).streamUser(authUser.uid);
}

/// Exposes the computed high-level authentication status of the application.
@riverpod
AuthStatus authStatus(Ref ref) {
  final authUserState = ref.watch(authUserProvider);
  final appUserState = ref.watch(appUserProvider);

  if (authUserState.isLoading || appUserState.isLoading) {
    return AuthStatus.initial;
  }

  final authUser = authUserState.value;
  if (authUser == null) {
    return AuthStatus.unauthenticated;
  }

  if (!authUser.emailVerified) {
    return AuthStatus.emailUnverified;
  }

  return AuthStatus.authenticated;
}

/// Controller for authentication-related UI actions.
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<Object?> build() {
    return null; // Initial state
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
          email: email,
          password: password,
        );
    
    if (result.isFailure) {
      AppLogger.error('SignIn failed for $email', error: result.exceptionOrNull, context: 'AuthController');
      state = AsyncError(result.exceptionOrNull!, StackTrace.current);
    } else {
      AppLogger.info('SignIn successful for $email', context: 'AuthController');
      state = const AsyncData(null);
    }
  }

  Future<void> signUp(String email, String password, String role) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signUpWithEmailAndPassword(
          email: email,
          password: password,
        );
    
    if (result.isFailure) {
      AppLogger.error('SignUp failed for $email', error: result.exceptionOrNull, context: 'AuthController');
      state = AsyncError(result.exceptionOrNull!, StackTrace.current);
    } else {
      AppLogger.info('SignUp successful for $email (role: $role). Updating user document...', context: 'AuthController');
      // Update role in Firestore immediately to override the default 'seller' set by Cloud Function
      try {
        final user = result.dataOrNull!;
        await ref.read(userRepositoryProvider).updateUser(
          AppUser(
            uid: user.uid,
            email: user.email ?? email,
            role: role,
          )
        );
      } catch (e, st) {
        AppLogger.error('Failed to update user role document', error: e, stackTrace: st, context: 'AuthController');
      }

      await ref.read(authRepositoryProvider).sendEmailVerification();
      AppLogger.info('Verification email sent to $email', context: 'AuthController');
      state = const AsyncData(null);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signOut();
    if (result.isFailure) {
      state = AsyncError(result.exceptionOrNull!, StackTrace.current);
    } else {
      state = const AsyncData(null);
    }
  }

  Future<void> resendVerificationEmail() async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).sendEmailVerification();
    if (result.isFailure) {
      state = AsyncError(result.exceptionOrNull!, StackTrace.current);
    } else {
      state = const AsyncData(null);
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
    if (result.isFailure) {
      state = AsyncError(result.exceptionOrNull!, StackTrace.current);
    } else {
      state = const AsyncData(null);
    }
  }
}
