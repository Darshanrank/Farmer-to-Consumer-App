import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kisanbazaar/models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream orders for a specific buyer
  Stream<List<OrderModel>> streamBuyerOrders(String buyerId) {
    return _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: buyerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  // Place an order (process cart items, check stock, create orders, clear cart)
  Future<void> placeOrder({
    required String buyerId,
    required String buyerName,
    required String buyerPhone,
    required String deliveryAddress,
    required String paymentMethod,
    required List<Map<String, dynamic>> cartItems,
  }) async {
    for (var item in cartItems) {
      String productId = item['productId'];
      String sellerId = item['sellerId'] ?? "";
      String productName = item['name'];
      int orderedQuantity = item['quantity'];
      double price = double.tryParse(item['price'].toString()) ?? 0.0;

      DocumentSnapshot productSnapshot = await _retry(() async {
        return await _firestore.collection("products").doc(productId).get();
      });

      if (!productSnapshot.exists) {
        final placeholderOrder = {
          "buyerId": buyerId,
          "buyerName": buyerName,
          "buyerPhone": buyerPhone,
          "sellerId": sellerId,
          "productId": productId,
          "productName": "$productName (Unavailable)",
          "quantity": orderedQuantity,
          "totalAmount": price * orderedQuantity,
          "total": price * orderedQuantity,
          "paymentMethod": paymentMethod,
          "deliveryAddress": deliveryAddress,
          "status": "pending",
          "image": item['imageUrl'] ?? item['image'] ?? '',
          "imageUrl": item['imageUrl'] ?? item['image'] ?? '',
          "timestamp": FieldValue.serverTimestamp(),
          "createdAt": FieldValue.serverTimestamp(),
          "orderDate": FieldValue.serverTimestamp(),
        };
        await _retry(() async {
          await _firestore.collection("orders").add(placeholderOrder);
        });
        continue;
      }

      Map<String, dynamic> productData = productSnapshot.data() as Map<String, dynamic>;
      int currentStock = productData['quantity'] ?? 0;

      if (currentStock < orderedQuantity) {
        throw Exception("Not enough stock available for $productName");
      }

      int updatedStock = currentStock - orderedQuantity;
      bool isAvailable = updatedStock > 0;

      try {
        await _firestore.collection("products").doc(productId).update({
          "quantity": updatedStock,
          "isAvailable": isAvailable,
        });
      } catch (e) {
        // Ignored permission error updating product stock
      }

      Map<String, dynamic> orderData = {
        "buyerId": buyerId,
        "buyerName": buyerName,
        "buyerPhone": buyerPhone,
        "sellerId": sellerId,
        "productId": productId,
        "productName": productName,
        "quantity": orderedQuantity,
        "totalAmount": price * orderedQuantity,
        "total": price * orderedQuantity,
        "paymentMethod": paymentMethod,
        "deliveryAddress": deliveryAddress,
        "status": "pending",
        "image": item['imageUrl'] ?? item['image'] ?? '',
        "imageUrl": item['imageUrl'] ?? item['image'] ?? '',
        "timestamp": FieldValue.serverTimestamp(),
        "createdAt": FieldValue.serverTimestamp(),
        "orderDate": FieldValue.serverTimestamp(),
      };

      await _retry(() async {
        await _firestore.collection("orders").add(orderData);
      });

      QuerySnapshot cartSnapshot = await _firestore.collection("cart").where("buyerId", isEqualTo: buyerId).get();
      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  Future<T> _retry<T>(Future<T> Function() action, {int retries = 3}) async {
    int attempt = 0;
    while (attempt < retries) {
      try {
        return await action();
      } catch (e) {
        attempt++;
        if (attempt >= retries) rethrow;
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    throw Exception("Retry failed after $retries attempts");
  }
}
