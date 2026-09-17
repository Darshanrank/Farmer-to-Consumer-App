import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../seller_inventory/domain/entities/product.dart';
import '../../../seller_inventory/data/product_repository.dart';
import '../../domain/entities/cart_item.dart';
import '../../data/cart_repository.dart';

part 'shopping_providers.g.dart';

/// Streams all active products for the buyer home feed.
@riverpod
Stream<List<Product>> buyerProducts(Ref ref) {
  return ref.watch(productRepositoryProvider).streamAllActiveProducts();
}

/// Streams the current user's cart items.
@riverpod
Stream<List<CartItem>> cart(Ref ref) {
  final user = ref.watch(authUserProvider).value;
  if (user == null) {
    return Stream.value([]);
  }
  return ref.watch(cartRepositoryProvider).streamCartItems(user.uid);
}

/// Computes the total price of all items in the cart.
@riverpod
double cartTotal(Ref ref) {
  final cartItems = ref.watch(cartProvider).value ?? [];
  return cartItems.fold(0.0, (total, item) => total + item.totalPrice);
}
