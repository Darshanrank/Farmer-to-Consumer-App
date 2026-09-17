import 'package:freezed_annotation/freezed_annotation.dart';
import 'cart_item.dart';

part 'customer_order.freezed.dart';
part 'customer_order.g.dart';

@freezed
abstract class CustomerOrder with _$CustomerOrder {
  const CustomerOrder._();

  const factory CustomerOrder({
    required String id,
    required String buyerId,
    required List<CartItem> items,
    required double totalAmount,
    required String status, // pending, confirmed, shipped, delivered, cancelled
    required String shippingAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CustomerOrder;

  factory CustomerOrder.fromJson(Map<String, dynamic> json) => _$CustomerOrderFromJson(json);
}
