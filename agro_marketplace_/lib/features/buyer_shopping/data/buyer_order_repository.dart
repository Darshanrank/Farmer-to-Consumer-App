import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/services/firebase_service.dart';
import '../../seller_orders/domain/entities/seller_order.dart';

part 'buyer_order_repository.g.dart';

/// Repository for handling buyer order queries.
/// It queries the `sellerOrders` collection to find packages assigned to the buyer.
class BuyerOrderRepository {
  final FirebaseFirestore _firestore;

  BuyerOrderRepository(this._firestore);

  /// Streams all order packages for a specific buyer.
  Stream<List<SellerOrder>> streamBuyerOrders(String buyerId) {
    return _firestore
        .collection('sellerOrders')
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => SellerOrder.fromJson(doc.data())).toList();
    });
  }
}

@riverpod
BuyerOrderRepository buyerOrderRepository(Ref ref) {
  return BuyerOrderRepository(ref.watch(firebaseServiceProvider).firestore);
}
