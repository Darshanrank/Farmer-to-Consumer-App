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

  /// Streams the user profile for the given [uid].
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
  
  /// Creates or updates a user profile.
  /// Normally, user creation is handled by Cloud Functions for security,
  /// but this provides an option to update user details from the client.
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
}

@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepository(ref.watch(firebaseServiceProvider).firestore);
}
