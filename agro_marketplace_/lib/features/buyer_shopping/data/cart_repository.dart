import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/commerce/commerce_rules.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/services/firebase_service.dart';
import '../../seller_inventory/domain/entities/product.dart';
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
          return snapshot.docs
              .map((doc) => CartItem.fromJson(doc.data()))
              .toList();
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

      await _firestore.runTransaction((transaction) async {
        final productRef = _firestore
            .collection(FirestorePaths.products)
            .doc(item.productId);
        final productSnap = await transaction.get(productRef);
        if (!productSnap.exists || productSnap.data() == null) {
          throw BusinessRuleException(
            message: 'Product is no longer available.',
          );
        }
        final product = Product.fromJson(productSnap.data()!);
        final cartSnap = await transaction.get(docRef);
        final existingItem = cartSnap.exists
            ? CartItem.fromJson(cartSnap.data()!)
            : null;
        final quantity = (existingItem?.quantity ?? 0) + item.quantity;
        final failure = InventoryRules.validateQuantity(
          product: product,
          quantity: quantity,
        );
        if (failure != null) throw BusinessRuleException(message: failure);
        transaction.set(
          docRef,
          (existingItem ?? item).copyWith(quantity: quantity).toJson(),
        );
      });
    });
  }

  Future<Result<void>> updateQuantity({
    required String userId,
    required String itemId,
    required int quantity,
  }) async {
    return Result.guard(() async {
      if (quantity <= 0) {
        throw BusinessRuleException(
          message: 'Quantity must be greater than zero.',
        );
      }
      final itemRef = _firestore
          .collection(FirestorePaths.users)
          .doc(userId)
          .collection('cartItems')
          .doc(itemId);
      await _firestore.runTransaction((transaction) async {
        final itemSnap = await transaction.get(itemRef);
        if (!itemSnap.exists || itemSnap.data() == null) {
          throw BusinessRuleException(
            message: 'Cart item is no longer available.',
          );
        }
        final item = CartItem.fromJson(itemSnap.data()!);
        final productRef = _firestore
            .collection(FirestorePaths.products)
            .doc(item.productId);
        final productSnap = await transaction.get(productRef);
        if (!productSnap.exists || productSnap.data() == null) {
          throw BusinessRuleException(
            message: 'Product is no longer available.',
          );
        }
        final failure = InventoryRules.validateQuantity(
          product: Product.fromJson(productSnap.data()!),
          quantity: quantity,
        );
        if (failure != null) throw BusinessRuleException(message: failure);
        transaction.update(itemRef, item.copyWith(quantity: quantity).toJson());
      });
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

  /// Removes only cart lines that are unchanged from the checkout snapshot.
  ///
  /// Items added or edited while checkout was running remain in the cart.
  Future<Result<void>> clearCartItemsIfUnchanged({
    required String userId,
    required List<CartItem> items,
  }) async {
    return Result.guard(() async {
      if (items.isEmpty) return;
      final cart = _firestore
          .collection(FirestorePaths.users)
          .doc(userId)
          .collection('cartItems');
      await _firestore.runTransaction((transaction) async {
        final snapshots =
            <(CartItem, DocumentSnapshot<Map<String, dynamic>>)>[];
        for (final item in items) {
          final snapshot = await transaction.get(cart.doc(item.id));
          snapshots.add((item, snapshot));
        }
        for (final entry in snapshots) {
          final snapshot = entry.$2;
          if (snapshot.exists &&
              snapshot.data() != null &&
              CartItem.fromJson(snapshot.data()!) == entry.$1) {
            transaction.delete(snapshot.reference);
          }
        }
      });
    });
  }
}

@riverpod
CartRepository cartRepository(Ref ref) {
  return CartRepository(ref.watch(firebaseServiceProvider).firestore);
}
