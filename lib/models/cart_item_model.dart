class CartItemModel {
  final String cartItemId; // Firestore document ID
  final String buyerId;
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String unit;
  final String imageUrl;
  final String sellerName;
  final String sellerId;

  CartItemModel({
    required this.cartItemId,
    required this.buyerId,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.imageUrl,
    required this.sellerName,
    required this.sellerId,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json, String docId) {
    return CartItemModel(
      cartItemId: docId,
      buyerId: json['buyerId'] ?? '',
      productId: json['productId'] ?? '',
      name: json['name'] ?? 'Product',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: json['quantity'] ?? 1,
      unit: json['unit'] ?? '/kg',
      imageUrl: json['image'] ?? json['imageUrl'] ?? '',
      sellerName: json['sellerName'] ?? json['seller_name'] ?? 'Seller',
      sellerId: json['sellerId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buyerId': buyerId,
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'image': imageUrl,
      'imageUrl': imageUrl, // legacy compat
      'sellerName': sellerName,
      'sellerId': sellerId,
    };
  }
}
