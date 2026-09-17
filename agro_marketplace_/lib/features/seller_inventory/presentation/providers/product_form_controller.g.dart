// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProductFormController)
final productFormControllerProvider = ProductFormControllerProvider._();

final class ProductFormControllerProvider
    extends $AsyncNotifierProvider<ProductFormController, void> {
  ProductFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productFormControllerHash();

  @$internal
  @override
  ProductFormController create() => ProductFormController();
}

String _$productFormControllerHash() =>
    r'58babebeeccc77d2a04809c56a42557cdcd50224';

abstract class _$ProductFormController extends $AsyncNotifier<void> {
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
