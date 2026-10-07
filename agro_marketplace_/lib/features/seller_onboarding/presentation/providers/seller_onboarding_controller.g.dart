// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SellerOnboardingController)
final sellerOnboardingControllerProvider =
    SellerOnboardingControllerProvider._();

final class SellerOnboardingControllerProvider
    extends $AsyncNotifierProvider<SellerOnboardingController, void> {
  SellerOnboardingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sellerOnboardingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sellerOnboardingControllerHash();

  @$internal
  @override
  SellerOnboardingController create() => SellerOnboardingController();
}

String _$sellerOnboardingControllerHash() =>
    r'c5d319a92fecbed279e87ad800902240f37de7aa';

abstract class _$SellerOnboardingController extends $AsyncNotifier<void> {
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
