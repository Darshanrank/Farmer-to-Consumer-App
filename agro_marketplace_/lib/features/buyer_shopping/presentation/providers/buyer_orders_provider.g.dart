// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buyer_orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Streams the order packages belonging to the currently authenticated buyer.

@ProviderFor(buyerOrders)
final buyerOrdersProvider = BuyerOrdersProvider._();

/// Streams the order packages belonging to the currently authenticated buyer.

final class BuyerOrdersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SellerOrder>>,
          List<SellerOrder>,
          Stream<List<SellerOrder>>
        >
    with
        $FutureModifier<List<SellerOrder>>,
        $StreamProvider<List<SellerOrder>> {
  /// Streams the order packages belonging to the currently authenticated buyer.
  BuyerOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'buyerOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$buyerOrdersHash();

  @$internal
  @override
  $StreamProviderElement<List<SellerOrder>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SellerOrder>> create(Ref ref) {
    return buyerOrders(ref);
  }
}

String _$buyerOrdersHash() => r'967d27815d8b2184b235bdd03e191201f6aaa2ce';
