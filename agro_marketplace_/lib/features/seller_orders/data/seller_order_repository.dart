import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
      return snapshot.docs.map((doc) => SellerOrder.fromJson(doc.data())).toList();
    });
  }

  /// Updates the status of a specific seller order.
  Future<Result<void>> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    return Result.guard(() async {
      final doc = await _firestore.collection('sellerOrders').doc(orderId).get();
      if (!doc.exists) return;
      final parentOrderId = doc.data()?['parentOrderId'] as String?;

      await _firestore
          .collection('sellerOrders')
          .doc(orderId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (parentOrderId != null) {
        final parentRef = _firestore.collection('customerOrders').doc(parentOrderId);
        
        final allSellerOrders = await _firestore
            .collection('sellerOrders')
            .where('parentOrderId', isEqualTo: parentOrderId)
            .get();
        
        bool allDelivered = true;
        
        for (final o in allSellerOrders.docs) {
          final currentStatus = (o.id == orderId) ? newStatus : (o.data()['status'] as String? ?? 'pending');
          if (currentStatus != 'delivered') allDelivered = false;
        }

        String overallStatus = newStatus;
        if (allDelivered) {
          overallStatus = 'delivered';
        }

        await parentRef.update({
          'status': overallStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}

@riverpod
SellerOrderRepository sellerOrderRepository(Ref ref) {
  return SellerOrderRepository(ref.watch(firebaseServiceProvider).firestore);
}
