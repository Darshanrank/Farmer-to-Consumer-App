// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Streams the orders assigned to the currently authenticated seller.

@ProviderFor(sellerOrders)
final sellerOrdersProvider = SellerOrdersProvider._();

/// Streams the orders assigned to the currently authenticated seller.

final class SellerOrdersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SellerOrder>>,
          List<SellerOrder>,
          Stream<List<SellerOrder>>
        >
    with
        $FutureModifier<List<SellerOrder>>,
        $StreamProvider<List<SellerOrder>> {
  /// Streams the orders assigned to the currently authenticated seller.
  SellerOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sellerOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sellerOrdersHash();

  @$internal
  @override
  $StreamProviderElement<List<SellerOrder>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SellerOrder>> create(Ref ref) {
    return sellerOrders(ref);
  }
}

String _$sellerOrdersHash() => r'6ff22810c8cc8217933e147b975642651c2c5618';
