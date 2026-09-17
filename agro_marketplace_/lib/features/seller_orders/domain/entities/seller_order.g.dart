// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SellerOrder _$SellerOrderFromJson(Map<String, dynamic> json) => _SellerOrder(
  id: json['id'] as String,
  parentOrderId: json['parentOrderId'] as String,
  buyerId: json['buyerId'] as String,
  sellerId: json['sellerId'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  status: json['status'] as String,
  shippingAddress: json['shippingAddress'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SellerOrderToJson(_SellerOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parentOrderId': instance.parentOrderId,
      'buyerId': instance.buyerId,
      'sellerId': instance.sellerId,
      'items': instance.items,
      'totalAmount': instance.totalAmount,
      'status': instance.status,
      'shippingAddress': instance.shippingAddress,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
