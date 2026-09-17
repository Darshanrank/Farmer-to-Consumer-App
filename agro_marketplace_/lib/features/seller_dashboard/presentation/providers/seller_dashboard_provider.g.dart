// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sellerDashboardMetrics)
final sellerDashboardMetricsProvider = SellerDashboardMetricsProvider._();

final class SellerDashboardMetricsProvider
    extends
        $FunctionalProvider<
          DashboardMetrics,
          DashboardMetrics,
          DashboardMetrics
        >
    with $Provider<DashboardMetrics> {
  SellerDashboardMetricsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sellerDashboardMetricsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sellerDashboardMetricsHash();

  @$internal
  @override
  $ProviderElement<DashboardMetrics> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DashboardMetrics create(Ref ref) {
    return sellerDashboardMetrics(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardMetrics value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardMetrics>(value),
    );
  }
}

String _$sellerDashboardMetricsHash() =>
    r'a1377c765b75b8d8ec915a3e04d60c471e66cc5c';

@ProviderFor(recentOrders)
final recentOrdersProvider = RecentOrdersProvider._();

final class RecentOrdersProvider
    extends
        $FunctionalProvider<
          List<SellerOrder>,
          List<SellerOrder>,
          List<SellerOrder>
        >
    with $Provider<List<SellerOrder>> {
  RecentOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentOrdersHash();

  @$internal
  @override
  $ProviderElement<List<SellerOrder>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SellerOrder> create(Ref ref) {
    return recentOrders(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SellerOrder> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SellerOrder>>(value),
    );
  }
}

String _$recentOrdersHash() => r'45e8e44341e41602a6c2218856b7b7b8990379ac';
