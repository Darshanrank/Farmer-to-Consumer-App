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
  stockQuantity: _parseInventoryInt(json['stockQuantity']),
  category: json['category'] as String,
  brand: json['brand'] as String?,
  minOrderQuantity: json['minOrderQuantity'] == null
      ? 1
      : _parseMinOrderQuantity(json['minOrderQuantity']),
  attributes: json['attributes'] as Map<String, dynamic>? ?? const {},
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  status: json['status'] as String? ?? 'active',
  supportsFastDelivery: json['supportsFastDelivery'] as bool? ?? false,
  supportsRegularDelivery: json['supportsRegularDelivery'] as bool? ?? false,
  sellerManagedFastDelivery:
      json['sellerManagedFastDelivery'] as bool? ?? false,
  sellerCountryCode: json['sellerCountryCode'] as String?,
  reservedQuantity: json['reservedQuantity'] == null
      ? 0
      : _parseInventoryInt(json['reservedQuantity']),
  soldQuantity: json['soldQuantity'] == null
      ? 0
      : _parseInventoryInt(json['soldQuantity']),
  ratingAverage: (json['ratingAverage'] as num?)?.toDouble() ?? 0,
  ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
  sellerServiceLocation: _locationFromJson(json['sellerServiceLocation']),
  fastDeliveryMinDays: (json['fastDeliveryMinDays'] as num?)?.toInt(),
  fastDeliveryMaxDays: (json['fastDeliveryMaxDays'] as num?)?.toInt(),
  regularDeliveryMinDays: (json['regularDeliveryMinDays'] as num?)?.toInt(),
  regularDeliveryMaxDays: (json['regularDeliveryMaxDays'] as num?)?.toInt(),
  fastDeliveryFee: (json['fastDeliveryFee'] as num?)?.toDouble(),
  regularDeliveryFee: (json['regularDeliveryFee'] as num?)?.toDouble(),
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
  'supportsFastDelivery': instance.supportsFastDelivery,
  'supportsRegularDelivery': instance.supportsRegularDelivery,
  'sellerManagedFastDelivery': instance.sellerManagedFastDelivery,
  'sellerCountryCode': instance.sellerCountryCode,
  'reservedQuantity': instance.reservedQuantity,
  'soldQuantity': instance.soldQuantity,
  'ratingAverage': instance.ratingAverage,
  'ratingCount': instance.ratingCount,
  'sellerServiceLocation': _locationToJson(instance.sellerServiceLocation),
  'fastDeliveryMinDays': instance.fastDeliveryMinDays,
  'fastDeliveryMaxDays': instance.fastDeliveryMaxDays,
  'regularDeliveryMinDays': instance.regularDeliveryMinDays,
  'regularDeliveryMaxDays': instance.regularDeliveryMaxDays,
  'fastDeliveryFee': instance.fastDeliveryFee,
  'regularDeliveryFee': instance.regularDeliveryFee,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
