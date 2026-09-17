// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Exposes the raw Firebase Auth user stream.

@ProviderFor(authUser)
final authUserProvider = AuthUserProvider._();

/// Exposes the raw Firebase Auth user stream.

final class AuthUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<firebase_auth.User?>,
          firebase_auth.User?,
          Stream<firebase_auth.User?>
        >
    with
        $FutureModifier<firebase_auth.User?>,
        $StreamProvider<firebase_auth.User?> {
  /// Exposes the raw Firebase Auth user stream.
  AuthUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authUserHash();

  @$internal
  @override
  $StreamProviderElement<firebase_auth.User?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<firebase_auth.User?> create(Ref ref) {
    return authUser(ref);
  }
}

String _$authUserHash() => r'6d15ae5c491bce26eb7af86602dcf5f7f401cdb8';

/// Exposes the Firestore `AppUser` profile for the currently authenticated user.

@ProviderFor(appUser)
final appUserProvider = AppUserProvider._();

/// Exposes the Firestore `AppUser` profile for the currently authenticated user.

final class AppUserProvider
    extends
        $FunctionalProvider<AsyncValue<AppUser?>, AppUser?, Stream<AppUser?>>
    with $FutureModifier<AppUser?>, $StreamProvider<AppUser?> {
  /// Exposes the Firestore `AppUser` profile for the currently authenticated user.
  AppUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUserHash();

  @$internal
  @override
  $StreamProviderElement<AppUser?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppUser?> create(Ref ref) {
    return appUser(ref);
  }
}

String _$appUserHash() => r'a7b31199a1fbfa34f2072ac506d1f021f22609ea';

/// Exposes the computed high-level authentication status of the application.

@ProviderFor(authStatus)
final authStatusProvider = AuthStatusProvider._();

/// Exposes the computed high-level authentication status of the application.

final class AuthStatusProvider
    extends $FunctionalProvider<AuthStatus, AuthStatus, AuthStatus>
    with $Provider<AuthStatus> {
  /// Exposes the computed high-level authentication status of the application.
  AuthStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStatusHash();

  @$internal
  @override
  $ProviderElement<AuthStatus> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthStatus create(Ref ref) {
    return authStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthStatus>(value),
    );
  }
}

String _$authStatusHash() => r'3218d335de3bf795c738cc152999a58852a9cf69';

/// Controller for authentication-related UI actions.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Controller for authentication-related UI actions.
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, Object?> {
  /// Controller for authentication-related UI actions.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'874374204f17a186a98b7cbed9e72db18360ad34';

/// Controller for authentication-related UI actions.

abstract class _$AuthController extends $AsyncNotifier<Object?> {
  FutureOr<Object?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Object?>, Object?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Object?>, Object?>,
              AsyncValue<Object?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
