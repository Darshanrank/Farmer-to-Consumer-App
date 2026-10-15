import '../../features/buyer_shopping/domain/entities/cart_item.dart';
import '../../features/buyer_shopping/domain/entities/checkout_quote.dart';

class CheckoutPricing {
  const CheckoutPricing._();

  static CheckoutQuote calculate(List<CartItem> items, {double? deliveryFee}) {
    final base = CheckoutQuote.fromItems(items);
    if (deliveryFee == null) return base;
    return CheckoutQuote(
      items: base.items,
      subtotal: base.subtotal,
      discount: base.discount,
      tax: base.tax,
      handlingFee: base.handlingFee,
      deliveryFee: deliveryFee,
    );
  }

  static Map<String, List<CartItem>> groupBySeller(List<CartItem> items) {
    final grouped = <String, List<CartItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.sellerId, () => []).add(item);
    }
    return grouped;
  }
}
