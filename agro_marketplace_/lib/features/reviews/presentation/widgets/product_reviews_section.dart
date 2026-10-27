import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/review_providers.dart';

class ProductReviewsSection extends ConsumerWidget {
  final String productId;

  const ProductReviewsSection({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(productReviewsProvider(productId));
    return reviews.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => Text('Could not load reviews: $error'),
      data: (items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reviews (${items.length})',
              style: Theme.of(context).textTheme.titleMedium),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No reviews yet.'),
            )
          else
            ...items.map(
              (review) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text('${review.rating} ★'),
                title: Text(review.text.isEmpty ? 'Rated purchase' : review.text),
                subtitle: Text(review.createdAt.toLocal().toString()),
              ),
            ),
        ],
      ),
    );
  }
}
