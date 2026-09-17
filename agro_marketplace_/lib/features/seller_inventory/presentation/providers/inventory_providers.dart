import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/product.dart';
import '../../data/product_repository.dart';

part 'inventory_providers.g.dart';

@riverpod
Stream<List<Product>> sellerProducts(Ref ref) {
  final user = ref.watch(authUserProvider).value;
  if (user == null) {
    return Stream.value([]);
  }
  
  return ref.watch(productRepositoryProvider).streamSellerProducts(user.uid);
}
