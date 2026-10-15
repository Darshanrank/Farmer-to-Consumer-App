import 'package:flutter_test/flutter_test.dart';
import 'package:agro_marketplace/core/commerce/checkout_pricing.dart';
import 'package:agro_marketplace/features/buyer_shopping/domain/entities/cart_item.dart';

void main() {
  test('calculates subtotal and configured charges for multiple items', () {
    final quote = CheckoutPricing.calculate([
      const CartItem(
        id: 'one',
        productId: 'p1',
        sellerId: 's1',
        name: 'Rice',
        price: 10,
        unit: 'kg',
        quantity: 2,
      ),
      const CartItem(
        id: 'two',
        productId: 'p2',
        sellerId: 's2',
        name: 'Wheat',
        price: 15,
        unit: 'kg',
        quantity: 1,
      ),
    ]);

    expect(quote.subtotal, 35);
    expect(quote.discount, 0);
    expect(quote.tax, 0);
    expect(quote.handlingFee, 0);
    expect(quote.deliveryFee, 50);
    expect(quote.total, 85);
  });

  test('groups a multi-seller cart without changing the parent total', () {
    final items = [
      const CartItem(
        id: 'one',
        productId: 'p1',
        sellerId: 'seller-a',
        name: 'Rice',
        price: 10,
        unit: 'kg',
        quantity: 1,
      ),
      const CartItem(
        id: 'two',
        productId: 'p2',
        sellerId: 'seller-b',
        name: 'Wheat',
        price: 20,
        unit: 'kg',
        quantity: 1,
      ),
      const CartItem(
        id: 'three',
        productId: 'p3',
        sellerId: 'seller-a',
        name: 'Dal',
        price: 5,
        unit: 'kg',
        quantity: 2,
      ),
    ];

    final grouped = CheckoutPricing.groupBySeller(items);

    expect(grouped.keys, containsAll(<String>['seller-a', 'seller-b']));
    expect(grouped['seller-a'], hasLength(2));
    expect(grouped['seller-b'], hasLength(1));
    expect(CheckoutPricing.calculate(items).subtotal, 40);
  });

  test('uses the latest cart snapshot prices supplied to the quote', () {
    final quote = CheckoutPricing.calculate([
      const CartItem(
        id: 'one',
        productId: 'p1',
        sellerId: 'seller-a',
        name: 'Updated product',
        price: 25,
        unit: 'kg',
        quantity: 2,
      ),
    ]);

    expect(quote.subtotal, 50);
    expect(quote.total, 100);
  });
}
