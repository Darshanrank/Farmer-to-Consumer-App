import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../seller_inventory/domain/entities/product.dart';
import '../../../seller_inventory/data/product_repository.dart';
import '../../domain/entities/cart_item.dart';
import '../../data/cart_repository.dart';
import '../../data/checkout_repository.dart';
import '../../../../core/commerce/product_listing_rules.dart';
import '../../../../shared/models/detailed_address.dart';
import '../../domain/entities/checkout_quote.dart';

part 'shopping_providers.g.dart';

/// Streams all active products for the buyer home feed.
@riverpod
Stream<List<Product>> buyerProducts(Ref ref) {
  return ref.watch(productRepositoryProvider).streamAllActiveProducts();
}

@riverpod
class ProductListingModeController extends _$ProductListingModeController {
  @override
  ProductListingMode build() => ProductListingMode.regular;

  void select(ProductListingMode mode) => state = mode;
}

@riverpod
class SelectedDeliveryAddressIndex extends _$SelectedDeliveryAddressIndex {
  @override
  int? build() {
    final user = ref.watch(appUserProvider).value;
    return user != null && user.savedAddresses.isNotEmpty ? 0 : null;
  }

  void select(int? index) => state = index;
}

@riverpod
DetailedAddress? selectedDeliveryAddress(Ref ref) {
  final index = ref.watch(selectedDeliveryAddressIndexProvider);
  final user = ref.watch(appUserProvider).value;
  if (index == null ||
      user == null ||
      index < 0 ||
      index >= user.savedAddresses.length) {
    return null;
  }
  return DetailedAddress.fromMap(user.savedAddresses[index]);
}

@riverpod
List<Product> buyerListingProducts(Ref ref) {
  final products = ref.watch(buyerProductsProvider).value ?? [];
  final mode = ref.watch(productListingModeControllerProvider);
  final address = ref.watch(selectedDeliveryAddressProvider);
  final buyerId = ref.watch(authUserProvider).value?.uid;
  return products.where((product) {
    // A seller viewing the buyer experience must not buy or browse their own
    // catalogue. This also applies immediately after switching roles.
    if (buyerId != null && product.sellerId == buyerId) return false;
    return ProductListingRules.evaluate(
      product: product,
      mode: mode,
      buyerAddress: address,
    ).isEligible;
  }).toList();
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

@riverpod
Future<CheckoutQuote?> checkoutQuote(Ref ref) async {
  final user = ref.watch(authUserProvider).value;
  final address = ref.watch(selectedDeliveryAddressProvider);
  if (user == null || address == null) return null;
  final result = await ref
      .watch(checkoutRepositoryProvider)
      .quoteOrder(
        buyerId: user.uid,
        deliveryMode: ref.watch(productListingModeControllerProvider),
        buyerAddress: address,
      );
  if (result.isFailure) {
    throw result.exceptionOrNull!;
  }
  return result.dataOrNull;
}
