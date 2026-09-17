// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_status_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OrderStatusController)
final orderStatusControllerProvider = OrderStatusControllerProvider._();

final class OrderStatusControllerProvider
    extends $AsyncNotifierProvider<OrderStatusController, void> {
  OrderStatusControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderStatusControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderStatusControllerHash();

  @$internal
  @override
  OrderStatusController create() => OrderStatusController();
}

String _$orderStatusControllerHash() =>
    r'512bc1c7a4181635792c46944624fe2d564436d7';

abstract class _$OrderStatusController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
