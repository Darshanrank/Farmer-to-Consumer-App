import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kisanbazaar/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Stream of current auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Fetch user profile from Firestore
  Stream<UserModel?> streamUserModel(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  Future<UserModel?> getUserModel(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    if (snapshot.exists && snapshot.data() != null) {
      return UserModel.fromJson(snapshot.data()!);
    }
    return null;
  }

  Future<void> updateUserAddresses(String uid, List<Map<String, dynamic>> addresses) async {
    await _firestore.collection('users').doc(uid).update({
      'addresses': addresses,
    });
  }

  Future<void> updateProfile(String uid, {required String phone, required String defaultAddress, required List<Map<String, dynamic>> addresses}) async {
    await _firestore.collection('users').doc(uid).update({
      'phone': phone,
      'address': defaultAddress, // legacy
      'addresses': addresses,
    });
  }
}
