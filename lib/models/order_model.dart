import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId; // Firestore document ID
  final String buyerId;
  final String buyerName;
  final String buyerPhone;
  final String sellerId;
  final String productId;
  final String productName;
  final int quantity;
  final double totalAmount;
  final String paymentMethod;
  final String deliveryAddress;
  final String status;
  final String imageUrl;
  final DateTime? createdAt;

  OrderModel({
    required this.orderId,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    required this.sellerId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.totalAmount,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.status,
    required this.imageUrl,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, String docId) {
    return OrderModel(
      orderId: docId,
      buyerId: json['buyerId'] ?? '',
      buyerName: json['buyerName'] ?? 'Buyer',
      buyerPhone: json['buyerPhone'] ?? '',
      sellerId: json['sellerId'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? 'Product',
      quantity: json['quantity'] ?? 1,
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? json['total']?.toString() ?? '0') ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? 'Cash on Delivery',
      deliveryAddress: json['deliveryAddress'] ?? '',
      status: json['status'] ?? 'pending',
      imageUrl: json['imageUrl'] ?? json['image'] ?? '',
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as Timestamp).toDate() 
          : (json['timestamp'] != null 
              ? (json['timestamp'] as Timestamp).toDate() 
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'sellerId': sellerId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'total': totalAmount, // legacy compat
      'paymentMethod': paymentMethod,
      'deliveryAddress': deliveryAddress,
      'status': status,
      'imageUrl': imageUrl,
      'image': imageUrl, // legacy compat
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'timestamp': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
