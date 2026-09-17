// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartItem _$CartItemFromJson(Map<String, dynamic> json) => _CartItem(
  id: json['id'] as String,
  productId: json['productId'] as String,
  sellerId: json['sellerId'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  unit: json['unit'] as String,
  quantity: (json['quantity'] as num).toInt(),
  imageBase64: json['imageBase64'] as String?,
  addedAt: json['addedAt'] == null
      ? null
      : DateTime.parse(json['addedAt'] as String),
);

Map<String, dynamic> _$CartItemToJson(_CartItem instance) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'sellerId': instance.sellerId,
  'name': instance.name,
  'price': instance.price,
  'unit': instance.unit,
  'quantity': instance.quantity,
  'imageBase64': instance.imageBase64,
  'addedAt': instance.addedAt?.toIso8601String(),
};
