import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../buyer_shopping/domain/entities/cart_item.dart';

part 'seller_order.freezed.dart';
part 'seller_order.g.dart';

@freezed
abstract class SellerOrder with _$SellerOrder {
  const SellerOrder._();

  const factory SellerOrder({
    required String id,
    required String parentOrderId, // The main CustomerOrder ID
    required String buyerId,
    required String sellerId,
    required List<CartItem> items, // Only the items belonging to this seller
    required double totalAmount, // Only the total for these specific items
    required String status, // pending, processing, shipped, delivered, cancelled
    required String shippingAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SellerOrder;

  factory SellerOrder.fromJson(Map<String, dynamic> json) => _$SellerOrderFromJson(json);
}
