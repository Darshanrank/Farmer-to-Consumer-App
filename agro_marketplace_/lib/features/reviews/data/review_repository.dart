import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/product_review.dart';

class ReviewRepository {
  final FirebaseFirestore firestore;

  ReviewRepository(this.firestore);

  Stream<List<ProductReview>> streamForProduct(String productId) =>
      firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map(ProductReview.fromSnapshot).toList());

}
