import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/services/firebase_service.dart';
import '../domain/entities/customer_order.dart';

part 'checkout_repository.g.dart';

/// Repository for handling checkout and order creation.
class CheckoutRepository {
  final FirebaseFirestore _firestore;

  CheckoutRepository(this._firestore);

  /// Places a new order and splits it into SellerOrders.
  Future<Result<void>> placeOrder(CustomerOrder order) async {
    return Result.guard(() async {
      final batch = _firestore.batch();
      
      // 1. Create the main CustomerOrder document
      final customerOrderRef = _firestore.collection(FirestorePaths.customerOrders).doc(order.id);
      batch.set(customerOrderRef, order.toJson());

      // 2. Group items by sellerId
      final Map<String, List> sellerItems = {};
      for (final item in order.items) {
        if (!sellerItems.containsKey(item.sellerId)) {
          sellerItems[item.sellerId] = [];
        }
        sellerItems[item.sellerId]!.add(item);
      }

      // 3. Create a SellerOrder for each seller
      for (final entry in sellerItems.entries) {
        final sellerId = entry.key;
        final items = entry.value;
        final sellerTotal = items.fold(0.0, (acc, item) => acc + item.totalPrice);
        
        final sellerOrderRef = _firestore.collection('sellerOrders').doc();
        batch.set(sellerOrderRef, {
          'id': sellerOrderRef.id,
          'parentOrderId': order.id,
          'buyerId': order.buyerId,
          'sellerId': sellerId,
          'items': items.map((i) => i.toJson()).toList(),
          'totalAmount': sellerTotal,
          'status': 'pending',
          'shippingAddress': order.shippingAddress,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Commit the batch
      await batch.commit();
    });
  }
}

@riverpod
CheckoutRepository checkoutRepository(Ref ref) {
  return CheckoutRepository(ref.watch(firebaseServiceProvider).firestore);
}
