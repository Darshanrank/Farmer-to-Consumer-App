import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String productId; // This will hold the Firestore document ID
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String unit;
  final int quantity;
  final String category;
  final String sellerName;
  final String imageUrl;
  final String sellerId;
  final String? harvestDate;
  final bool isAvailable;
  final DateTime? createdAt;

  ProductModel({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.unit,
    required this.quantity,
    required this.category,
    required this.sellerName,
    required this.imageUrl,
    required this.sellerId,
    this.harvestDate,
    this.isAvailable = true,
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json, String docId) {
    return ProductModel(
      productId: docId,
      name: json['name'] ?? 'Unknown Product',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      originalPrice: json['originalPrice'] != null ? double.tryParse(json['originalPrice'].toString()) : null,
      unit: json['unit'] ?? '/kg',
      quantity: json['quantity'] ?? 0,
      category: json['category'] ?? 'Other',
      sellerName: json['seller_name'] ?? json['sellerName'] ?? 'Seller',
      imageUrl: json['imageUrl'] ?? json['image'] ?? '',
      sellerId: json['sellerId'] ?? '',
      harvestDate: json['harvest_date'] ?? json['harvestDate'],
      isAvailable: json['isAvailable'] ?? true,
      createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      if (originalPrice != null) 'originalPrice': originalPrice,
      'unit': unit,
      'quantity': quantity,
      'category': category,
      'seller_name': sellerName,
      'imageUrl': imageUrl,
      'image': imageUrl, // legacy compat
      'sellerId': sellerId,
      if (harvestDate != null) 'harvest_date': harvestDate,
      'isAvailable': isAvailable,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
