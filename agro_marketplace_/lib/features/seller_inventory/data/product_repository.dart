import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/services/firebase_service.dart';
import '../domain/entities/product.dart';

part 'product_repository.g.dart';

/// Repository for handling Firestore product operations.
class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository(this._firestore);

  /// Streams all active products globally (for buyers).
  Stream<List<Product>> streamAllActiveProducts() {
    return _firestore
        .collection(FirestorePaths.products)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList();
    });
  }

  /// Streams all products for a given seller.
  Stream<List<Product>> streamSellerProducts(String sellerId) {
    return _firestore
        .collection(FirestorePaths.products)
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList();
    });
  }

  /// Creates a new product.
  Future<Result<void>> createProduct(Product product) async {
    return Result.guard(() async {
      final data = product.toJson();
      data['images'] = product.images.map((img) => img.toJson()).toList();
      
      await _firestore
          .collection(FirestorePaths.products)
          .doc(product.id)
          .set(data);
    });
  }

  /// Updates an existing product.
  Future<Result<void>> updateProduct(Product product) async {
    return Result.guard(() async {
      product = product.copyWith(updatedAt: DateTime.now());
      final data = product.toJson();
      data['images'] = product.images.map((img) => img.toJson()).toList();

      await _firestore
          .collection(FirestorePaths.products)
          .doc(product.id)
          .update(data);
    });
  }

  /// Deletes a product.
  Future<Result<void>> deleteProduct(String productId) async {
    return Result.guard(() async {
      await _firestore.collection(FirestorePaths.products).doc(productId).delete();
    });
  }
}

@riverpod
ProductRepository productRepository(Ref ref) {
  return ProductRepository(ref.watch(firebaseServiceProvider).firestore);
}
