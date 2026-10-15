import 'package:flutter_test/flutter_test.dart';
import 'package:agro_marketplace/core/commerce/order_lifecycle.dart';

void main() {
  test('allows only the next seller lifecycle transition', () {
    expect(
      OrderLifecycle.canTransition(
        from: 'pending',
        to: 'accepted',
        actor: OrderActor.seller,
      ),
      isTrue,
    );
    expect(
      OrderLifecycle.canTransition(
        from: 'pending',
        to: 'delivered',
        actor: OrderActor.seller,
      ),
      isFalse,
    );
    expect(
      OrderLifecycle.canTransition(
        from: 'dispatched',
        to: 'delivered',
        actor: OrderActor.seller,
      ),
      isTrue,
    );
  });

  test('derives parent status from all seller packages', () {
    expect(
      OrderLifecycle.parentStatusForSellerStatuses(['delivered', 'delivered']),
      'delivered',
    );
    expect(
      OrderLifecycle.parentStatusForSellerStatuses(['delivered', 'preparing']),
      'processing',
    );
    expect(
      OrderLifecycle.parentStatusForSellerStatuses(['rejected', 'delivered']),
      'partially_fulfilled',
    );
  });
}
