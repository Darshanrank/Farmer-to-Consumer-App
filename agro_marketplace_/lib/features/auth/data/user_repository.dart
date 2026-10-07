import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/services/firebase_service.dart';
import '../domain/entities/app_user.dart';

part 'user_repository.g.dart';

/// Repository for handling Firestore user profiles.
class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  Stream<AppUser?> streamUser(String uid) {
    return _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return AppUser.fromJson(snapshot.data()!);
    });
  }

  /// Fetches a user profile synchronously.
  Future<Result<AppUser?>> getUser(String uid) async {
    return Result.guard(() async {
      final snapshot = await _firestore.collection(FirestorePaths.users).doc(uid).get();
      if (!snapshot.exists || snapshot.data() == null) return null;
      return AppUser.fromJson(snapshot.data()!);
    });
  }
  
  /// Creates the initial user document including role.
  /// Called once on registration so the role ('buyer' or 'seller') is
  /// persisted correctly before any Cloud Function can overwrite it.
  Future<Result<void>> createUserDocument(AppUser user) async {
    return Result.guard(() async {
      final payload = user.toJson();
      // Keep role on creation – this is the only time we intentionally write it.
      payload.remove('isEmailVerified');
      payload['createdAt'] = DateTime.now().toIso8601String();

      await _firestore
          .collection(FirestorePaths.users)
          .doc(user.uid)
          .set(payload, SetOptions(merge: false)); // merge: false = full create
    });
  }

  /// Creates or updates a user profile (non-sensitive fields only).
  /// Does NOT write role/status/isEmailVerified to protect security rules.
  Future<Result<void>> updateUser(AppUser user) async {
    return Result.guard(() async {
      // Remove secure fields from the payload to prevent Firestore permission errors
      // under our strict security rules.
      final payload = user.toJson();
      payload.remove('role');
      payload.remove('status');
      payload.remove('isEmailVerified');

      await _firestore
          .collection(FirestorePaths.users)
          .doc(user.uid)
          .set(payload, SetOptions(merge: true));
    });
  }

  /// Updates the user's role directly (e.g. switching between buyer and seller).
  Future<Result<void>> updateUserRole(String uid, String newRole) async {
    return Result.guard(() async {
      await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .set({'role': newRole}, SetOptions(merge: true));
    });
  }

  /// Deletes the user's Firestore document.
  /// Called as part of the delete account flow.
  Future<Result<void>> deleteUserDocument(String uid) async {
    return Result.guard(() async {
      await _firestore.collection(FirestorePaths.users).doc(uid).delete();
    });
  }
}

@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepository(ref.watch(firebaseServiceProvider).firestore);
}
