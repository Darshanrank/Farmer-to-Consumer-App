import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/services/firebase_service.dart';
import '../domain/entities/cart_item.dart';

part 'cart_repository.g.dart';

/// Repository for handling buyer cart operations in Firestore.
class CartRepository {
  final FirebaseFirestore _firestore;

  CartRepository(this._firestore);

  /// Streams the current user's cart items.
  Stream<List<CartItem>> streamCartItems(String userId) {
    return _firestore
        .collection(FirestorePaths.users)
        .doc(userId)
        .collection('cartItems')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CartItem.fromJson(doc.data())).toList();
    });
  }

  /// Adds or updates an item in the cart.
  Future<Result<void>> addToCart({
    required String userId,
    required CartItem item,
  }) async {
    return Result.guard(() async {
      final docRef = _firestore
          .collection(FirestorePaths.users)
          .doc(userId)
          .collection('cartItems')
          .doc(item.id);

      final docSnap = await docRef.get();
      if (docSnap.exists) {
        final existingItem = CartItem.fromJson(docSnap.data()!);
        final updatedItem = existingItem.copyWith(
          quantity: existingItem.quantity + item.quantity,
        );
        await docRef.set(updatedItem.toJson());
      } else {
        await docRef.set(item.toJson());
      }
    });
  }

  /// Removes an item from the cart.
  Future<Result<void>> removeFromCart({
    required String userId,
    required String itemId,
  }) async {
    return Result.guard(() async {
      await _firestore
          .collection(FirestorePaths.users)
          .doc(userId)
          .collection('cartItems')
          .doc(itemId)
          .delete();
    });
  }

  /// Clears the entire cart for a user.
  Future<Result<void>> clearCart(String userId) async {
    return Result.guard(() async {
      final snapshot = await _firestore
          .collection(FirestorePaths.users)
          .doc(userId)
          .collection('cartItems')
          .get();
      
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    });
  }
}

@riverpod
CartRepository cartRepository(Ref ref) {
  return CartRepository(ref.watch(firebaseServiceProvider).firestore);
}
