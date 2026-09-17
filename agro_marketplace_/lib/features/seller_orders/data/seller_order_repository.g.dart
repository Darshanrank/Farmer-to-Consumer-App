// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_order_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sellerOrderRepository)
final sellerOrderRepositoryProvider = SellerOrderRepositoryProvider._();

final class SellerOrderRepositoryProvider
    extends
        $FunctionalProvider<
          SellerOrderRepository,
          SellerOrderRepository,
          SellerOrderRepository
        >
    with $Provider<SellerOrderRepository> {
  SellerOrderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sellerOrderRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sellerOrderRepositoryHash();

  @$internal
  @override
  $ProviderElement<SellerOrderRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SellerOrderRepository create(Ref ref) {
    return sellerOrderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SellerOrderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SellerOrderRepository>(value),
    );
  }
}

String _$sellerOrderRepositoryHash() =>
    r'281aa9d11864dd090cee1fd688303a1104301da9';
