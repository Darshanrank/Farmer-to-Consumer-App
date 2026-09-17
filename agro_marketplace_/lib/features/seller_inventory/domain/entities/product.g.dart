// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  sellerId: json['sellerId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  unit: json['unit'] as String,
  stockQuantity: (json['stockQuantity'] as num).toInt(),
  category: json['category'] as String,
  brand: json['brand'] as String?,
  minOrderQuantity: (json['minOrderQuantity'] as num?)?.toInt() ?? 1,
  attributes: json['attributes'] as Map<String, dynamic>? ?? const {},
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  status: json['status'] as String? ?? 'active',
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'sellerId': instance.sellerId,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'unit': instance.unit,
  'stockQuantity': instance.stockQuantity,
  'category': instance.category,
  'brand': instance.brand,
  'minOrderQuantity': instance.minOrderQuantity,
  'attributes': instance.attributes,
  'images': instance.images,
  'status': instance.status,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
