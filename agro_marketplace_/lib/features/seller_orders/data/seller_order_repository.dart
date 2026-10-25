import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/result/result.dart';
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
      final orderRef = _firestore.collection('sellerOrders').doc(orderId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(orderRef);
        final order = snapshot.data();
        if (!snapshot.exists || order == null) {
          throw BusinessRuleException(message: 'Seller order was not found.');
        }
        final currentStatus = order['status'] as String? ?? 'pending';
        final items = order['items'];
        final shouldReduceStock =
            currentStatus == 'pending' && newStatus == 'accepted';
        final shouldRestoreStock =
            currentStatus == 'accepted' && newStatus == 'cancelled';
        if (shouldReduceStock || shouldRestoreStock) {
          if (items is! List) {
            throw BusinessRuleException(message: 'Order items are invalid.');
          }
          final productRefs = <DocumentReference<Map<String, dynamic>>>[];
          final quantities = <int>[];
          for (final item in items) {
            if (item is! Map) {
              throw BusinessRuleException(message: 'Order items are invalid.');
            }
            final productId = item['productId'];
            final quantity = item['quantity'];
            if (productId is! String ||
                quantity is! num ||
                quantity <= 0 ||
                quantity != quantity.truncateToDouble()) {
              throw BusinessRuleException(message: 'Order items are invalid.');
            }
            productRefs.add(_firestore.collection('products').doc(productId));
            quantities.add(quantity.toInt());
          }
          final productSnapshots = <DocumentSnapshot<Map<String, dynamic>>>[];
          for (final productRef in productRefs) {
            productSnapshots.add(await transaction.get(productRef));
          }
          for (var index = 0; index < productSnapshots.length; index++) {
            final product = productSnapshots[index].data();
            if (!productSnapshots[index].exists || product == null) {
              throw BusinessRuleException(message: 'Product was not found.');
            }
            final sold = product['soldQuantity'];
            if (sold is! num || sold < 0 || sold != sold.truncateToDouble()) {
              throw BusinessRuleException(message: 'Product inventory is invalid.');
            }
            final nextSold = sold.toInt() +
                (shouldReduceStock ? quantities[index] : -quantities[index]);
            if (nextSold < 0) {
              throw BusinessRuleException(
                message: 'Product inventory is inconsistent.',
              );
            }
            transaction.update(productRefs[index], {
              'soldQuantity': nextSold,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
        transaction.update(orderRef, {
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    });
  }

  Future<Result<void>> assignTransport({
    required String orderId,
    required Map<String, dynamic> transport,
  }) async {
    return Result.guard(() async {
      final orderRef = _firestore.collection('sellerOrders').doc(orderId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(orderRef);
        if (!snapshot.exists || snapshot.data() == null) {
          throw BusinessRuleException(message: 'Seller order was not found.');
        }
        transaction.update(orderRef, {
          'transportAssignment': transport,
          'deliveryStage': 'assigned',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    });
  }

  Future<Result<void>> updateDeliveryStage({
    required String orderId,
    required String stage,
  }) async {
    return Result.guard(() async {
      const stages = {
        'assigned',
        'picked_up',
        'in_transit',
        'delivered',
        'failed',
        'returned',
      };
      if (!stages.contains(stage)) {
        throw BusinessRuleException(message: 'Delivery stage is invalid.');
      }
      final orderRef = _firestore.collection('sellerOrders').doc(orderId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(orderRef);
        final order = snapshot.data();
        if (!snapshot.exists || order == null) {
          throw BusinessRuleException(message: 'Seller order was not found.');
        }
        final current = order['deliveryStage'] as String? ?? 'assigned';
        const transitions = {
          'assigned': {'picked_up', 'failed'},
          'picked_up': {'in_transit', 'failed'},
          'in_transit': {'delivered', 'failed'},
          'delivered': <String>{},
          'failed': {'returned'},
          'returned': <String>{},
        };
        if (!transitions.containsKey(current) ||
            !transitions[current]!.contains(stage)) {
          throw BusinessRuleException(
            message: 'Cannot move delivery from $current to $stage.',
          );
        }
        transaction.update(orderRef, {
          'deliveryStage': stage,
          'updatedAt': FieldValue.serverTimestamp(),
          if (stage == 'delivered') ...{
            'fulfilmentStatus': 'delivered',
            'status': 'delivered',
            'deliveredAt': FieldValue.serverTimestamp(),
          },
        });
      });
    });
  }
}

@riverpod
SellerOrderRepository sellerOrderRepository(Ref ref) {
  final firebase = ref.watch(firebaseServiceProvider);
  return SellerOrderRepository(firebase.firestore);
}
