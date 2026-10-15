import 'package:uuid/uuid.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/models/detailed_address.dart';
import '../../data/cart_repository.dart';
import '../../data/checkout_repository.dart';
import '../../domain/entities/customer_order.dart';
import 'shopping_providers.dart';

part 'checkout_controller.g.dart';

@riverpod
class CheckoutController extends _$CheckoutController {
  String? _pendingOrderId;
  bool _submissionInProgress = false;

  @override
  FutureOr<void> build() {
    return null;
  }

  /// Places an order using the current cart items.
  Future<Result<void>> placeOrder({
    required String shippingAddress,
    required DetailedAddress buyerAddress,
  }) async {
    if (_submissionInProgress) {
      return Result.failure(
        BusinessRuleException(message: 'Checkout is already being submitted.'),
      );
    }
    _submissionInProgress = true;
    state = const AsyncLoading();

    final user = ref.read(authUserProvider).value;
    if (user == null) {
      _submissionInProgress = false;
      final ex = Exception('User is not authenticated');
      state = AsyncError(ex, StackTrace.current);
      return Result.failure(
        AuthenticationException(
          message: 'User is not authenticated',
          originalError: ex,
        ),
      );
    }
    final cartSnapshot = ref.read(cartProvider).value ?? const [];

    final orderId = _pendingOrderId ??= const Uuid().v4();

    final order = CustomerOrder(
      id: orderId,
      buyerId: user.uid,
      items: const [],
      totalAmount: 0,
      status: 'pending',
      shippingAddress: shippingAddress,
      deliveryMode: ref.read(productListingModeControllerProvider).name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await Result.guard(() async {
      // The repository re-reads the cart, address, products, prices, stock and
      // delivery eligibility before writing the parent and seller orders.
      final placeResult = await ref
          .read(checkoutRepositoryProvider)
          .placeOrder(
            order,
            deliveryMode: ref.read(productListingModeControllerProvider),
            buyerAddress: buyerAddress,
          );
      if (placeResult.isFailure) throw placeResult.exceptionOrNull!;

      final clearResult = await ref
          .read(cartRepositoryProvider)
          .clearCartItemsIfUnchanged(userId: user.uid, items: cartSnapshot);
      // The order batch has already succeeded. A cleanup failure must not
      // tell the buyer that the order failed or cause a duplicate retry.
      // Unchanged lines remain visible and can be removed on the next cart
      // refresh; newly added lines are never touched.
      if (clearResult.isFailure) {
        state = AsyncError(clearResult.exceptionOrNull!, StackTrace.current);
      }
    });

    if (result.isSuccess) {
      _pendingOrderId = null;
      state = const AsyncData(null);
    } else {
      // A failed batch must not be retried with an ID that may already exist
      // from a previous attempt or an older app build.
      _pendingOrderId = null;
      state = AsyncError(result.exceptionOrNull!, StackTrace.current);
    }
    _submissionInProgress = false;
    return result;
  }
}
