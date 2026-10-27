import 'package:cloud_firestore/cloud_firestore.dart';

class ProductReview {
  final String id;
  final String productId;
  final String reviewerId;
  final int rating;
  final String text;
  final DateTime createdAt;

  const ProductReview({
    required this.id,
    required this.productId,
    required this.reviewerId,
    required this.rating,
    required this.text,
    required this.createdAt,
  });

  factory ProductReview.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final createdAt = data['createdAt'];
    return ProductReview(
      id: snapshot.id,
      productId: data['productId'] as String? ?? '',
      reviewerId: data['reviewerId'] as String? ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      text: data['text'] as String? ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }
}
