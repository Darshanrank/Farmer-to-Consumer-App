import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/result/result.dart';
import '../../../../core/commerce/order_lifecycle.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../shared/services/firebase_service.dart';
import '../domain/entities/seller_order.dart';

part 'seller_order_repository.g.dart';

/// Repository for handling seller order operations in Firestore.
class SellerOrderRepository {
  final FirebaseFirestore _firestore;

  SellerOrderRepository(this._firestore);

  /// Streams all orders assigned to a specific seller.
  Stream<List<SellerOrder>> streamSellerOrders(String sellerId) {
    return _firestore
        .collection('sellerOrders')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            for (final field in ['createdAt', 'updatedAt']) {
              final value = data[field];
              if (value is Timestamp) {
                data[field] = value.toDate().toIso8601String();
              }
            }
            return SellerOrder.fromJson(data);
          }).toList();
        });
  }

  /// Updates the status of a specific seller order.
  Future<Result<void>> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    return Result.guard(() async {
      final sellerOrderRef = _firestore.collection('sellerOrders').doc(orderId);
      final doc = await sellerOrderRef.get();
      if (!doc.exists) {
        throw BusinessRuleException(message: 'Order was not found.');
      }
      final currentStatus = doc.data()?['status'] as String? ?? 'pending';
      if (!OrderLifecycle.canTransition(
        from: currentStatus,
        to: newStatus,
        actor: OrderActor.seller,
      )) {
        throw BusinessRuleException(
          message: 'Cannot move an order from $currentStatus to $newStatus.',
        );
      }
      await _firestore.runTransaction((transaction) async {
        final current = await transaction.get(sellerOrderRef);
        final latestStatus = current.data()?['status'] as String? ?? 'pending';
        if (!OrderLifecycle.canTransition(
          from: latestStatus,
          to: newStatus,
          actor: OrderActor.seller,
        )) {
          throw BusinessRuleException(
            message: 'Order status changed. Refresh and try again.',
          );
        }
        transaction.update(sellerOrderRef, {
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      // Parent status aggregation requires reading every seller package.
      // Rules prevent a seller from reading packages assigned to other
      // sellers, so trusted backend processing must perform that aggregation.
    });
  }
}

@riverpod
SellerOrderRepository sellerOrderRepository(Ref ref) {
  return SellerOrderRepository(ref.watch(firebaseServiceProvider).firestore);
}
