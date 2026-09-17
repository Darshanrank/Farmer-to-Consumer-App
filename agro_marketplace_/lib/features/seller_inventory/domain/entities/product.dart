import 'package:freezed_annotation/freezed_annotation.dart';

import 'product_image.dart';

part 'product.freezed.dart';
part 'product.g.dart';

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
    required int stockQuantity,
    required String category,
    String? brand,
    @Default(1) int minOrderQuantity,
    @Default({}) Map<String, dynamic> attributes,
    @Default([]) List<ProductImage> images,
    @Default('active') String status, // active, outOfStock, hidden
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  bool get isOutOfStock => stockQuantity <= 0 || status == 'outOfStock';
}
