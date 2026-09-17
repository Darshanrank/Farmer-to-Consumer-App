import 'package:uuid/uuid.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/cart_repository.dart';
import '../../data/checkout_repository.dart';
import '../../domain/entities/customer_order.dart';
import 'shopping_providers.dart';

part 'checkout_controller.g.dart';

@riverpod
class CheckoutController extends _$CheckoutController {
  @override
  FutureOr<void> build() {
    return null;
  }

  /// Places an order using the current cart items.
  Future<Result<void>> placeOrder({
    required String shippingAddress,
  }) async {
    state = const AsyncLoading();

    final user = ref.read(authUserProvider).value;
    if (user == null) {
      final ex = Exception('User is not authenticated');
      state = AsyncError(ex, StackTrace.current);
      return Result.failure(AuthenticationException(message: 'User is not authenticated', originalError: ex));
    }

    final cartItems = ref.read(cartProvider).value ?? [];
    if (cartItems.isEmpty) {
      final ex = Exception('Cart is empty');
      state = AsyncError(ex, StackTrace.current);
      return Result.failure(BusinessRuleException(message: 'Cannot place order with an empty cart.', originalError: ex));
    }

    final totalAmount = ref.read(cartTotalProvider);
    final orderId = const Uuid().v4();

    final order = CustomerOrder(
      id: orderId,
      buyerId: user.uid,
      items: cartItems,
      totalAmount: totalAmount,
      status: 'pending',
      shippingAddress: shippingAddress,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await Result.guard(() async {
      // 1. Place order
      final placeResult = await ref.read(checkoutRepositoryProvider).placeOrder(order);
      if (placeResult.isFailure) throw placeResult.exceptionOrNull!;

      // 2. Clear cart
      final clearResult = await ref.read(cartRepositoryProvider).clearCart(user.uid);
      if (clearResult.isFailure) throw clearResult.exceptionOrNull!;
    });

    if (result.isSuccess) {
      state = const AsyncData(null);
    } else {
      state = AsyncError(result.exceptionOrNull!, StackTrace.current);
    }

    return result;
  }
}
