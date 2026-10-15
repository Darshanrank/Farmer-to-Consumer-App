import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/models/location.dart';
import 'product_image.dart';

part 'product.freezed.dart';
part 'product.g.dart';

int _parseInventoryInt(Object? value, {int invalidValue = -1}) {
  if (value is num && value.isFinite && value == value.truncateToDouble()) {
    return value.toInt();
  }

  if (value is String) {
    final parsed = int.tryParse(value.trim());
    if (parsed != null) return parsed;
  }
  return invalidValue;
}

int _parseMinOrderQuantity(Object? value) =>
    _parseInventoryInt(value, invalidValue: 1);

GeoLocation? _locationFromJson(Object? value) {
  if (value is! Map) return null;
  try {
    return GeoLocation.fromMap(Map<String, dynamic>.from(value));
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? _locationToJson(GeoLocation? value) => value?.toMap();

@freezed
abstract class Product with _$Product {
  const Product._();

  const factory Product({
    required String id,
    required String sellerId,
    required String name,
    required String description,
    required double price,
    required String unit,
    @JsonKey(fromJson: _parseInventoryInt) required int stockQuantity,
    required String category,
    String? brand,
    @JsonKey(fromJson: _parseMinOrderQuantity) @Default(1) int minOrderQuantity,
    @Default({}) Map<String, dynamic> attributes,
    @Default([]) List<ProductImage> images,
    @Default('active') String status, // active, outOfStock, hidden
    @Default(false) bool supportsFastDelivery,
    @Default(false) bool supportsRegularDelivery,
    @Default(false) bool sellerManagedFastDelivery,
    String? sellerCountryCode,
    @JsonKey(fromJson: _parseInventoryInt) @Default(0) int reservedQuantity,
    @JsonKey(fromJson: _parseInventoryInt) @Default(0) int soldQuantity,
    @JsonKey(fromJson: _locationFromJson, toJson: _locationToJson)
    GeoLocation? sellerServiceLocation,
    int? fastDeliveryMinDays,
    int? fastDeliveryMaxDays,
    int? regularDeliveryMinDays,
    int? regularDeliveryMaxDays,
    double? fastDeliveryFee,
    double? regularDeliveryFee,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  bool get isOutOfStock => stockQuantity <= 0 || status == 'outOfStock';

  bool get isAvailableForPurchase =>
      status == 'active' &&
      stockQuantity >= 0 &&
      reservedQuantity >= 0 &&
      soldQuantity >= 0 &&
      minOrderQuantity > 0 &&
      availableQuantity > 0;

  String get availabilityLabel =>
      isAvailableForPurchase ? 'Available' : 'Out of stock';

  /// Stock that can still be committed to a new order.
  ///
  /// Missing legacy reservation/sold fields deserialize to zero, while
  /// negative values are treated as invalid by [InventoryRules].
  int get availableQuantity => stockQuantity - reservedQuantity - soldQuantity;
}
