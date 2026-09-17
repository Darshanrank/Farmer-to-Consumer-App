// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Streams all active products for the buyer home feed.

@ProviderFor(buyerProducts)
final buyerProductsProvider = BuyerProductsProvider._();

/// Streams all active products for the buyer home feed.

final class BuyerProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Product>>,
          List<Product>,
          Stream<List<Product>>
        >
    with $FutureModifier<List<Product>>, $StreamProvider<List<Product>> {
  /// Streams all active products for the buyer home feed.
  BuyerProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'buyerProductsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$buyerProductsHash();

  @$internal
  @override
  $StreamProviderElement<List<Product>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Product>> create(Ref ref) {
    return buyerProducts(ref);
  }
}

String _$buyerProductsHash() => r'd134dbfed55635cc6e442f9a5f8a9e2291bd00b2';

/// Streams the current user's cart items.

@ProviderFor(cart)
final cartProvider = CartProvider._();

/// Streams the current user's cart items.

final class CartProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CartItem>>,
          List<CartItem>,
          Stream<List<CartItem>>
        >
    with $FutureModifier<List<CartItem>>, $StreamProvider<List<CartItem>> {
  /// Streams the current user's cart items.
  CartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartHash();

  @$internal
  @override
  $StreamProviderElement<List<CartItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CartItem>> create(Ref ref) {
    return cart(ref);
  }
}

String _$cartHash() => r'bd6e902de5647805dbafd4c852564f67a729306a';

/// Computes the total price of all items in the cart.

@ProviderFor(cartTotal)
final cartTotalProvider = CartTotalProvider._();

/// Computes the total price of all items in the cart.

final class CartTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Computes the total price of all items in the cart.
  CartTotalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartTotalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartTotalHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return cartTotal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$cartTotalHash() => r'77fbdab63ccc97557f04bd3c8eca0dc7dafba03b';
