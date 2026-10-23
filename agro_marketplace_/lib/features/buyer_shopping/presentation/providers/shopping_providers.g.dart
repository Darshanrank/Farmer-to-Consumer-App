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

@ProviderFor(ProductListingModeController)
final productListingModeControllerProvider =
    ProductListingModeControllerProvider._();

final class ProductListingModeControllerProvider
    extends
        $NotifierProvider<ProductListingModeController, ProductListingMode> {
  ProductListingModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productListingModeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productListingModeControllerHash();

  @$internal
  @override
  ProductListingModeController create() => ProductListingModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductListingMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductListingMode>(value),
    );
  }
}

String _$productListingModeControllerHash() =>
    r'9f24e1965b40cf13a7fbe27188b7f7b803b8550d';

abstract class _$ProductListingModeController
    extends $Notifier<ProductListingMode> {
  ProductListingMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ProductListingMode, ProductListingMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProductListingMode, ProductListingMode>,
              ProductListingMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedDeliveryAddressIndex)
final selectedDeliveryAddressIndexProvider =
    SelectedDeliveryAddressIndexProvider._();

final class SelectedDeliveryAddressIndexProvider
    extends $NotifierProvider<SelectedDeliveryAddressIndex, int?> {
  SelectedDeliveryAddressIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDeliveryAddressIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDeliveryAddressIndexHash();

  @$internal
  @override
  SelectedDeliveryAddressIndex create() => SelectedDeliveryAddressIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$selectedDeliveryAddressIndexHash() =>
    r'51655cb704d6fe2fbe0dc7fd818ee1493496b280';

abstract class _$SelectedDeliveryAddressIndex extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(selectedDeliveryAddress)
final selectedDeliveryAddressProvider = SelectedDeliveryAddressProvider._();

final class SelectedDeliveryAddressProvider
    extends
        $FunctionalProvider<
          DetailedAddress?,
          DetailedAddress?,
          DetailedAddress?
        >
    with $Provider<DetailedAddress?> {
  SelectedDeliveryAddressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDeliveryAddressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDeliveryAddressHash();

  @$internal
  @override
  $ProviderElement<DetailedAddress?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DetailedAddress? create(Ref ref) {
    return selectedDeliveryAddress(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DetailedAddress? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DetailedAddress?>(value),
    );
  }
}

String _$selectedDeliveryAddressHash() =>
    r'897285becd7184bd0f270c2a95dfe03d8a49c919';

@ProviderFor(buyerListingProducts)
final buyerListingProductsProvider = BuyerListingProductsProvider._();

final class BuyerListingProductsProvider
    extends $FunctionalProvider<List<Product>, List<Product>, List<Product>>
    with $Provider<List<Product>> {
  BuyerListingProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'buyerListingProductsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$buyerListingProductsHash();

  @$internal
  @override
  $ProviderElement<List<Product>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Product> create(Ref ref) {
    return buyerListingProducts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Product> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Product>>(value),
    );
  }
}

String _$buyerListingProductsHash() =>
    r'e40287ceff95f3f9616e7fcaafe552fd39220630';

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

@ProviderFor(checkoutQuote)
final checkoutQuoteProvider = CheckoutQuoteProvider._();

final class CheckoutQuoteProvider
    extends
        $FunctionalProvider<
          AsyncValue<CheckoutQuote?>,
          CheckoutQuote?,
          FutureOr<CheckoutQuote?>
        >
    with $FutureModifier<CheckoutQuote?>, $FutureProvider<CheckoutQuote?> {
  CheckoutQuoteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkoutQuoteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkoutQuoteHash();

  @$internal
  @override
  $FutureProviderElement<CheckoutQuote?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CheckoutQuote?> create(Ref ref) {
    return checkoutQuote(ref);
  }
}

String _$checkoutQuoteHash() => r'774e6e68da160e3af5972c9e88f279d21b71a546';
