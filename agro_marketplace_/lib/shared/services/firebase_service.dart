import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Centralized Firebase service instances.
///
/// Provides singleton access to Firebase services throughout the app.
/// This abstraction makes it easy to switch to emulators or mock in tests.
class FirebaseService {
  static FirebaseService? _instance;

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  FirebaseService._({
    required this.auth,
    required this.firestore,
  });

  /// Returns the singleton instance.
  static FirebaseService get instance {
    _instance ??= FirebaseService._(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'default',
      ),
    );
    return _instance!;
  }

  /// Creates a test instance with custom Firebase mocks.
  static FirebaseService createForTest({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) {
    return FirebaseService._(
      auth: auth,
      firestore: firestore,
    );
  }

  /// Current authenticated user (null if not signed in).
  User? get currentUser => auth.currentUser;

  /// Current user UID (throws if not authenticated).
  String get currentUserId {
    final user = currentUser;
    if (user == null) throw StateError('User is not authenticated');
    return user.uid;
  }

  /// Whether a user is currently authenticated.
  bool get isAuthenticated => currentUser != null;

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => auth.authStateChanges();

  /// Firestore collection reference helper.
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      firestore.collection(path);

  /// Firestore document reference helper.
  DocumentReference<Map<String, dynamic>> document(String path) =>
      firestore.doc(path);
}

/// Riverpod provider for FirebaseService.
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService.instance;
});
