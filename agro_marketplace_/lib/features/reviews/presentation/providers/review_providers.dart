import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/services/firebase_service.dart';
import '../../data/review_repository.dart';
import '../../domain/entities/product_review.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.watch(firebaseServiceProvider).firestore);
});

final productReviewsProvider =
    StreamProvider.family<List<ProductReview>, String>((ref, productId) {
  return ref.watch(reviewRepositoryProvider).streamForProduct(productId);
});
