import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

@freezed
abstract class CartItem with _$CartItem {
  const CartItem._();

  const factory CartItem({
    required String id, // Usually same as productId for uniqueness per cart
    required String productId,
    required String sellerId,
    required String name,
    required double price,
    required String unit,
    required int quantity,
    String? imageBase64,
    DateTime? addedAt,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);

  double get totalPrice => price * quantity;
}
