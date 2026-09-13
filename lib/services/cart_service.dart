import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kisanbazaar/models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream cart items for a specific buyer
  Stream<List<CartItemModel>> streamCartItems(String buyerId) {
    return _firestore
        .collection('cart')
        .where('buyerId', isEqualTo: buyerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CartItemModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  // Add a product to cart
  Future<void> addToCart({
    required String buyerId,
    required Map<String, dynamic> productData,
  }) async {
    final String productId = productData['productId'];
    QuerySnapshot existing = await _firestore
        .collection('cart')
        .where('buyerId', isEqualTo: buyerId)
        .where('productId', isEqualTo: productId)
        .get();

    if (existing.docs.isNotEmpty) {
      // Item already in cart, increment quantity
      await existing.docs.first.reference.update({
        'quantity': (existing.docs.first['quantity'] ?? 0) + 1,
      });
    } else {
      // Add new item to cart
      await _firestore.collection('cart').add({
        'buyerId': buyerId,
        'productId': productId,
        'name': productData['name'],
        'price': productData['price'],
        'quantity': 1,
        'unit': productData['unit'] ?? '/kg',
        'image': productData['imageUrl'] ?? productData['image'] ?? '',
        'sellerName': productData['seller_name'] ?? productData['sellerName'] ?? 'Seller',
        'sellerId': productData['sellerId'] ?? '',
      });
    }
  }

  // Update cart item quantity
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(cartItemId);
    } else {
      await _firestore.collection('cart').doc(cartItemId).update({'quantity': newQuantity});
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    await _firestore.collection('cart').doc(cartItemId).delete();
  }
}
