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
          return snapshot.docs
              .map((doc) => Product.fromJson(doc.data()))
              .toList();
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
          return snapshot.docs
              .map((doc) => Product.fromJson(doc.data()))
              .toList();
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
      await _firestore
          .collection(FirestorePaths.products)
          .doc(productId)
          .delete();
    });
  }

  Future<Result<void>> updateSellerDeliverySnapshot({
    required String sellerId,
    required bool fastEnabled,
    required bool regularEnabled,
    required String countryCode,
    required Map<String, dynamic>? origin,
    required int? fastMinDays,
    required int? fastMaxDays,
    required int? regularMinDays,
    required int? regularMaxDays,
    required double? fastFee,
    required double? regularFee,
  }) async {
    return Result.guard(() async {
      final snapshot = await _firestore
          .collection(FirestorePaths.products)
          .where('sellerId', isEqualTo: sellerId)
          .get();
      WriteBatch? batch;
      var writes = 0;
      Future<void> commitBatch() async {
        if (batch != null && writes > 0) {
          await batch!.commit();
        }
        batch = null;
        writes = 0;
      }

      for (final doc in snapshot.docs) {
        batch ??= _firestore.batch();
        batch!.update(doc.reference, {
          'supportsFastDelivery': fastEnabled,
          'supportsRegularDelivery': regularEnabled,
          'sellerManagedFastDelivery': fastEnabled,
          'sellerCountryCode': countryCode,
          'sellerServiceLocation': origin,
          'fastDeliveryMinDays': fastMinDays,
          'fastDeliveryMaxDays': fastMaxDays,
          'regularDeliveryMinDays': regularMinDays,
          'regularDeliveryMaxDays': regularMaxDays,
          'fastDeliveryFee': fastFee,
          'regularDeliveryFee': regularFee,
          'updatedAt': DateTime.now().toIso8601String(),
        });
        writes++;
        if (writes == 500) await commitBatch();
      }
      await commitBatch();
    });
  }

  /// Fetches a single product by ID.
  Future<Result<Product?>> getProduct(String productId) async {
    return Result.guard(() async {
      final doc = await _firestore
          .collection(FirestorePaths.products)
          .doc(productId)
          .get();
      if (!doc.exists || doc.data() == null) return null;
      return Product.fromJson(doc.data()!);
    });
  }
}

@riverpod
ProductRepository productRepository(Ref ref) {
  return ProductRepository(ref.watch(firebaseServiceProvider).firestore);
}
