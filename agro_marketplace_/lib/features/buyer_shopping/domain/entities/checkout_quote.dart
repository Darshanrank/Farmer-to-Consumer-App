import '../../../../core/constants/app_constants.dart';
import 'cart_item.dart';

class CheckoutQuote {
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double handlingFee;
  final double deliveryFee;

  const CheckoutQuote({
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.handlingFee,
    required this.deliveryFee,
  });

  double get total => subtotal - discount + tax + handlingFee + deliveryFee;

  static CheckoutQuote fromItems(List<CartItem> items) {
    final subtotal = items.fold<double>(
      0,
      (total, item) => total + item.totalPrice,
    );
    return CheckoutQuote(
      items: List.unmodifiable(items),
      subtotal: subtotal,
      discount: 0,
      tax: 0,
      handlingFee: 0,
      deliveryFee: AppConstants.deliveryFee,
    );
  }
}
