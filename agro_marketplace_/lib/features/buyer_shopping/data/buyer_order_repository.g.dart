// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buyer_order_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(buyerOrderRepository)
final buyerOrderRepositoryProvider = BuyerOrderRepositoryProvider._();

final class BuyerOrderRepositoryProvider
    extends
        $FunctionalProvider<
          BuyerOrderRepository,
          BuyerOrderRepository,
          BuyerOrderRepository
        >
    with $Provider<BuyerOrderRepository> {
  BuyerOrderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'buyerOrderRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$buyerOrderRepositoryHash();

  @$internal
  @override
  $ProviderElement<BuyerOrderRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BuyerOrderRepository create(Ref ref) {
    return buyerOrderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BuyerOrderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BuyerOrderRepository>(value),
    );
  }
}

String _$buyerOrderRepositoryHash() =>
    r'8cab51c37be39b6b06407706c14dd9f24bcb487b';
