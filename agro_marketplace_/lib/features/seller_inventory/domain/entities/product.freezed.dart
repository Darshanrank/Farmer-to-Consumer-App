// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product {

 String get id; String get sellerId; String get name; String get description; double get price; String get unit;@JsonKey(fromJson: _parseInventoryInt) int get stockQuantity; String get category; String? get brand;@JsonKey(fromJson: _parseMinOrderQuantity) int get minOrderQuantity; Map<String, dynamic> get attributes; List<ProductImage> get images; String get status; bool get supportsFastDelivery; bool get supportsRegularDelivery; bool get sellerManagedFastDelivery; String? get sellerCountryCode;@JsonKey(fromJson: _parseInventoryInt) int get reservedQuantity;@JsonKey(fromJson: _parseInventoryInt) int get soldQuantity; double get ratingAverage; int get ratingCount;@JsonKey(fromJson: _locationFromJson, toJson: _locationToJson) GeoLocation? get sellerServiceLocation; int? get fastDeliveryMinDays; int? get fastDeliveryMaxDays; int? get regularDeliveryMinDays; int? get regularDeliveryMaxDays; double? get fastDeliveryFee; double? get regularDeliveryFee; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Product;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sellerId, _this.sellerId) || other.sellerId == _this.sellerId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.stockQuantity, _this.stockQuantity) || other.stockQuantity == _this.stockQuantity)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.minOrderQuantity, _this.minOrderQuantity) || other.minOrderQuantity == _this.minOrderQuantity)&&const DeepCollectionEquality().equals(other.attributes, _this.attributes)&&const DeepCollectionEquality().equals(other.images, _this.images)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.supportsFastDelivery, _this.supportsFastDelivery) || other.supportsFastDelivery == _this.supportsFastDelivery)&&(identical(other.supportsRegularDelivery, _this.supportsRegularDelivery) || other.supportsRegularDelivery == _this.supportsRegularDelivery)&&(identical(other.sellerManagedFastDelivery, _this.sellerManagedFastDelivery) || other.sellerManagedFastDelivery == _this.sellerManagedFastDelivery)&&(identical(other.sellerCountryCode, _this.sellerCountryCode) || other.sellerCountryCode == _this.sellerCountryCode)&&(identical(other.reservedQuantity, _this.reservedQuantity) || other.reservedQuantity == _this.reservedQuantity)&&(identical(other.soldQuantity, _this.soldQuantity) || other.soldQuantity == _this.soldQuantity)&&(identical(other.ratingAverage, _this.ratingAverage) || other.ratingAverage == _this.ratingAverage)&&(identical(other.ratingCount, _this.ratingCount) || other.ratingCount == _this.ratingCount)&&(identical(other.sellerServiceLocation, _this.sellerServiceLocation) || other.sellerServiceLocation == _this.sellerServiceLocation)&&(identical(other.fastDeliveryMinDays, _this.fastDeliveryMinDays) || other.fastDeliveryMinDays == _this.fastDeliveryMinDays)&&(identical(other.fastDeliveryMaxDays, _this.fastDeliveryMaxDays) || other.fastDeliveryMaxDays == _this.fastDeliveryMaxDays)&&(identical(other.regularDeliveryMinDays, _this.regularDeliveryMinDays) || other.regularDeliveryMinDays == _this.regularDeliveryMinDays)&&(identical(other.regularDeliveryMaxDays, _this.regularDeliveryMaxDays) || other.regularDeliveryMaxDays == _this.regularDeliveryMaxDays)&&(identical(other.fastDeliveryFee, _this.fastDeliveryFee) || other.fastDeliveryFee == _this.fastDeliveryFee)&&(identical(other.regularDeliveryFee, _this.regularDeliveryFee) || other.regularDeliveryFee == _this.regularDeliveryFee)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Product;
  return Object.hashAll([runtimeType,_this.id,_this.sellerId,_this.name,_this.description,_this.price,_this.unit,_this.stockQuantity,_this.category,_this.brand,_this.minOrderQuantity,const DeepCollectionEquality().hash(_this.attributes),const DeepCollectionEquality().hash(_this.images),_this.status,_this.supportsFastDelivery,_this.supportsRegularDelivery,_this.sellerManagedFastDelivery,_this.sellerCountryCode,_this.reservedQuantity,_this.soldQuantity,_this.ratingAverage,_this.ratingCount,_this.sellerServiceLocation,_this.fastDeliveryMinDays,_this.fastDeliveryMaxDays,_this.regularDeliveryMinDays,_this.regularDeliveryMaxDays,_this.fastDeliveryFee,_this.regularDeliveryFee,_this.createdAt,_this.updatedAt]);
}

@override
String toString() {
  final _this = this as Product;
  return 'Product(id: ${_this.id}, sellerId: ${_this.sellerId}, name: ${_this.name}, description: ${_this.description}, price: ${_this.price}, unit: ${_this.unit}, stockQuantity: ${_this.stockQuantity}, category: ${_this.category}, brand: ${_this.brand}, minOrderQuantity: ${_this.minOrderQuantity}, attributes: ${_this.attributes}, images: ${_this.images}, status: ${_this.status}, supportsFastDelivery: ${_this.supportsFastDelivery}, supportsRegularDelivery: ${_this.supportsRegularDelivery}, sellerManagedFastDelivery: ${_this.sellerManagedFastDelivery}, sellerCountryCode: ${_this.sellerCountryCode}, reservedQuantity: ${_this.reservedQuantity}, soldQuantity: ${_this.soldQuantity}, ratingAverage: ${_this.ratingAverage}, ratingCount: ${_this.ratingCount}, sellerServiceLocation: ${_this.sellerServiceLocation}, fastDeliveryMinDays: ${_this.fastDeliveryMinDays}, fastDeliveryMaxDays: ${_this.fastDeliveryMaxDays}, regularDeliveryMinDays: ${_this.regularDeliveryMinDays}, regularDeliveryMaxDays: ${_this.regularDeliveryMaxDays}, fastDeliveryFee: ${_this.fastDeliveryFee}, regularDeliveryFee: ${_this.regularDeliveryFee}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String id, String sellerId, String name, String description, double price, String unit,@JsonKey(fromJson: _parseInventoryInt) int stockQuantity, String category, String? brand,@JsonKey(fromJson: _parseMinOrderQuantity) int minOrderQuantity, Map<String, dynamic> attributes, List<ProductImage> images, String status, bool supportsFastDelivery, bool supportsRegularDelivery, bool sellerManagedFastDelivery, String? sellerCountryCode,@JsonKey(fromJson: _parseInventoryInt) int reservedQuantity,@JsonKey(fromJson: _parseInventoryInt) int soldQuantity, double ratingAverage, int ratingCount,@JsonKey(fromJson: _locationFromJson, toJson: _locationToJson) GeoLocation? sellerServiceLocation, int? fastDeliveryMinDays, int? fastDeliveryMaxDays, int? regularDeliveryMinDays, int? regularDeliveryMaxDays, double? fastDeliveryFee, double? regularDeliveryFee, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sellerId = null,Object? name = null,Object? description = null,Object? price = null,Object? unit = null,Object? stockQuantity = null,Object? category = null,Object? brand = freezed,Object? minOrderQuantity = null,Object? attributes = null,Object? images = null,Object? status = null,Object? supportsFastDelivery = null,Object? supportsRegularDelivery = null,Object? sellerManagedFastDelivery = null,Object? sellerCountryCode = freezed,Object? reservedQuantity = null,Object? soldQuantity = null,Object? ratingAverage = null,Object? ratingCount = null,Object? sellerServiceLocation = freezed,Object? fastDeliveryMinDays = freezed,Object? fastDeliveryMaxDays = freezed,Object? regularDeliveryMinDays = freezed,Object? regularDeliveryMaxDays = freezed,Object? fastDeliveryFee = freezed,Object? regularDeliveryFee = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,stockQuantity: null == stockQuantity ? _self.stockQuantity : stockQuantity // ignore: cast_nullable_to_non_nullable
as int,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,minOrderQuantity: null == minOrderQuantity ? _self.minOrderQuantity : minOrderQuantity // ignore: cast_nullable_to_non_nullable
as int,attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<ProductImage>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,supportsFastDelivery: null == supportsFastDelivery ? _self.supportsFastDelivery : supportsFastDelivery // ignore: cast_nullable_to_non_nullable
as bool,supportsRegularDelivery: null == supportsRegularDelivery ? _self.supportsRegularDelivery : supportsRegularDelivery // ignore: cast_nullable_to_non_nullable
as bool,sellerManagedFastDelivery: null == sellerManagedFastDelivery ? _self.sellerManagedFastDelivery : sellerManagedFastDelivery // ignore: cast_nullable_to_non_nullable
as bool,sellerCountryCode: freezed == sellerCountryCode ? _self.sellerCountryCode : sellerCountryCode // ignore: cast_nullable_to_non_nullable
as String?,reservedQuantity: null == reservedQuantity ? _self.reservedQuantity : reservedQuantity // ignore: cast_nullable_to_non_nullable
as int,soldQuantity: null == soldQuantity ? _self.soldQuantity : soldQuantity // ignore: cast_nullable_to_non_nullable
as int,ratingAverage: null == ratingAverage ? _self.ratingAverage : ratingAverage // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,sellerServiceLocation: freezed == sellerServiceLocation ? _self.sellerServiceLocation : sellerServiceLocation // ignore: cast_nullable_to_non_nullable
as GeoLocation?,fastDeliveryMinDays: freezed == fastDeliveryMinDays ? _self.fastDeliveryMinDays : fastDeliveryMinDays // ignore: cast_nullable_to_non_nullable
as int?,fastDeliveryMaxDays: freezed == fastDeliveryMaxDays ? _self.fastDeliveryMaxDays : fastDeliveryMaxDays // ignore: cast_nullable_to_non_nullable
as int?,regularDeliveryMinDays: freezed == regularDeliveryMinDays ? _self.regularDeliveryMinDays : regularDeliveryMinDays // ignore: cast_nullable_to_non_nullable
as int?,regularDeliveryMaxDays: freezed == regularDeliveryMaxDays ? _self.regularDeliveryMaxDays : regularDeliveryMaxDays // ignore: cast_nullable_to_non_nullable
as int?,fastDeliveryFee: freezed == fastDeliveryFee ? _self.fastDeliveryFee : fastDeliveryFee // ignore: cast_nullable_to_non_nullable
as double?,regularDeliveryFee: freezed == regularDeliveryFee ? _self.regularDeliveryFee : regularDeliveryFee // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sellerId,  String name,  String description,  double price,  String unit, @JsonKey(fromJson: _parseInventoryInt)  int stockQuantity,  String category,  String? brand, @JsonKey(fromJson: _parseMinOrderQuantity)  int minOrderQuantity,  Map<String, dynamic> attributes,  List<ProductImage> images,  String status,  bool supportsFastDelivery,  bool supportsRegularDelivery,  bool sellerManagedFastDelivery,  String? sellerCountryCode, @JsonKey(fromJson: _parseInventoryInt)  int reservedQuantity, @JsonKey(fromJson: _parseInventoryInt)  int soldQuantity,  double ratingAverage,  int ratingCount, @JsonKey(fromJson: _locationFromJson, toJson: _locationToJson)  GeoLocation? sellerServiceLocation,  int? fastDeliveryMinDays,  int? fastDeliveryMaxDays,  int? regularDeliveryMinDays,  int? regularDeliveryMaxDays,  double? fastDeliveryFee,  double? regularDeliveryFee,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.sellerId,_that.name,_that.description,_that.price,_that.unit,_that.stockQuantity,_that.category,_that.brand,_that.minOrderQuantity,_that.attributes,_that.images,_that.status,_that.supportsFastDelivery,_that.supportsRegularDelivery,_that.sellerManagedFastDelivery,_that.sellerCountryCode,_that.reservedQuantity,_that.soldQuantity,_that.ratingAverage,_that.ratingCount,_that.sellerServiceLocation,_that.fastDeliveryMinDays,_that.fastDeliveryMaxDays,_that.regularDeliveryMinDays,_that.regularDeliveryMaxDays,_that.fastDeliveryFee,_that.regularDeliveryFee,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sellerId,  String name,  String description,  double price,  String unit, @JsonKey(fromJson: _parseInventoryInt)  int stockQuantity,  String category,  String? brand, @JsonKey(fromJson: _parseMinOrderQuantity)  int minOrderQuantity,  Map<String, dynamic> attributes,  List<ProductImage> images,  String status,  bool supportsFastDelivery,  bool supportsRegularDelivery,  bool sellerManagedFastDelivery,  String? sellerCountryCode, @JsonKey(fromJson: _parseInventoryInt)  int reservedQuantity, @JsonKey(fromJson: _parseInventoryInt)  int soldQuantity,  double ratingAverage,  int ratingCount, @JsonKey(fromJson: _locationFromJson, toJson: _locationToJson)  GeoLocation? sellerServiceLocation,  int? fastDeliveryMinDays,  int? fastDeliveryMaxDays,  int? regularDeliveryMinDays,  int? regularDeliveryMaxDays,  double? fastDeliveryFee,  double? regularDeliveryFee,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.sellerId,_that.name,_that.description,_that.price,_that.unit,_that.stockQuantity,_that.category,_that.brand,_that.minOrderQuantity,_that.attributes,_that.images,_that.status,_that.supportsFastDelivery,_that.supportsRegularDelivery,_that.sellerManagedFastDelivery,_that.sellerCountryCode,_that.reservedQuantity,_that.soldQuantity,_that.ratingAverage,_that.ratingCount,_that.sellerServiceLocation,_that.fastDeliveryMinDays,_that.fastDeliveryMaxDays,_that.regularDeliveryMinDays,_that.regularDeliveryMaxDays,_that.fastDeliveryFee,_that.regularDeliveryFee,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sellerId,  String name,  String description,  double price,  String unit, @JsonKey(fromJson: _parseInventoryInt)  int stockQuantity,  String category,  String? brand, @JsonKey(fromJson: _parseMinOrderQuantity)  int minOrderQuantity,  Map<String, dynamic> attributes,  List<ProductImage> images,  String status,  bool supportsFastDelivery,  bool supportsRegularDelivery,  bool sellerManagedFastDelivery,  String? sellerCountryCode, @JsonKey(fromJson: _parseInventoryInt)  int reservedQuantity, @JsonKey(fromJson: _parseInventoryInt)  int soldQuantity,  double ratingAverage,  int ratingCount, @JsonKey(fromJson: _locationFromJson, toJson: _locationToJson)  GeoLocation? sellerServiceLocation,  int? fastDeliveryMinDays,  int? fastDeliveryMaxDays,  int? regularDeliveryMinDays,  int? regularDeliveryMaxDays,  double? fastDeliveryFee,  double? regularDeliveryFee,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.sellerId,_that.name,_that.description,_that.price,_that.unit,_that.stockQuantity,_that.category,_that.brand,_that.minOrderQuantity,_that.attributes,_that.images,_that.status,_that.supportsFastDelivery,_that.supportsRegularDelivery,_that.sellerManagedFastDelivery,_that.sellerCountryCode,_that.reservedQuantity,_that.soldQuantity,_that.ratingAverage,_that.ratingCount,_that.sellerServiceLocation,_that.fastDeliveryMinDays,_that.fastDeliveryMaxDays,_that.regularDeliveryMinDays,_that.regularDeliveryMaxDays,_that.fastDeliveryFee,_that.regularDeliveryFee,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product extends Product {
  const _Product({required this.id, required this.sellerId, required this.name, required this.description, required this.price, required this.unit, @JsonKey(fromJson: _parseInventoryInt) required this.stockQuantity, required this.category, this.brand, @JsonKey(fromJson: _parseMinOrderQuantity) this.minOrderQuantity = 1,  Map<String, dynamic> attributes = const {},  List<ProductImage> images = const [], this.status = 'active', this.supportsFastDelivery = false, this.supportsRegularDelivery = false, this.sellerManagedFastDelivery = false, this.sellerCountryCode, @JsonKey(fromJson: _parseInventoryInt) this.reservedQuantity = 0, @JsonKey(fromJson: _parseInventoryInt) this.soldQuantity = 0, this.ratingAverage = 0, this.ratingCount = 0, @JsonKey(fromJson: _locationFromJson, toJson: _locationToJson) this.sellerServiceLocation, this.fastDeliveryMinDays, this.fastDeliveryMaxDays, this.regularDeliveryMinDays, this.regularDeliveryMaxDays, this.fastDeliveryFee, this.regularDeliveryFee, this.createdAt, this.updatedAt}): _attributes = attributes,_images = images,super._();
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  String id;
@override final  String sellerId;
@override final  String name;
@override final  String description;
@override final  double price;
@override final  String unit;
@override@JsonKey(fromJson: _parseInventoryInt) final  int stockQuantity;
@override final  String category;
@override final  String? brand;
@override@JsonKey(fromJson: _parseMinOrderQuantity) final  int minOrderQuantity;
 final  Map<String, dynamic> _attributes;
@override@JsonKey() Map<String, dynamic> get attributes {
  if (_attributes is EqualUnmodifiableMapView) return _attributes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_attributes);
}

 final  List<ProductImage> _images;
@override@JsonKey() List<ProductImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override@JsonKey() final  String status;
@override@JsonKey() final  bool supportsFastDelivery;
@override@JsonKey() final  bool supportsRegularDelivery;
@override@JsonKey() final  bool sellerManagedFastDelivery;
@override final  String? sellerCountryCode;
@override@JsonKey(fromJson: _parseInventoryInt) final  int reservedQuantity;
@override@JsonKey(fromJson: _parseInventoryInt) final  int soldQuantity;
@override@JsonKey() final  double ratingAverage;
@override@JsonKey() final  int ratingCount;
@override@JsonKey(fromJson: _locationFromJson, toJson: _locationToJson) final  GeoLocation? sellerServiceLocation;
@override final  int? fastDeliveryMinDays;
@override final  int? fastDeliveryMaxDays;
@override final  int? regularDeliveryMinDays;
@override final  int? regularDeliveryMaxDays;
@override final  double? fastDeliveryFee;
@override final  double? regularDeliveryFee;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.stockQuantity, stockQuantity) || other.stockQuantity == stockQuantity)&&(identical(other.category, category) || other.category == category)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.minOrderQuantity, minOrderQuantity) || other.minOrderQuantity == minOrderQuantity)&&const DeepCollectionEquality().equals(other.attributes, _attributes)&&const DeepCollectionEquality().equals(other.images, _images)&&(identical(other.status, status) || other.status == status)&&(identical(other.supportsFastDelivery, supportsFastDelivery) || other.supportsFastDelivery == supportsFastDelivery)&&(identical(other.supportsRegularDelivery, supportsRegularDelivery) || other.supportsRegularDelivery == supportsRegularDelivery)&&(identical(other.sellerManagedFastDelivery, sellerManagedFastDelivery) || other.sellerManagedFastDelivery == sellerManagedFastDelivery)&&(identical(other.sellerCountryCode, sellerCountryCode) || other.sellerCountryCode == sellerCountryCode)&&(identical(other.reservedQuantity, reservedQuantity) || other.reservedQuantity == reservedQuantity)&&(identical(other.soldQuantity, soldQuantity) || other.soldQuantity == soldQuantity)&&(identical(other.ratingAverage, ratingAverage) || other.ratingAverage == ratingAverage)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.sellerServiceLocation, sellerServiceLocation) || other.sellerServiceLocation == sellerServiceLocation)&&(identical(other.fastDeliveryMinDays, fastDeliveryMinDays) || other.fastDeliveryMinDays == fastDeliveryMinDays)&&(identical(other.fastDeliveryMaxDays, fastDeliveryMaxDays) || other.fastDeliveryMaxDays == fastDeliveryMaxDays)&&(identical(other.regularDeliveryMinDays, regularDeliveryMinDays) || other.regularDeliveryMinDays == regularDeliveryMinDays)&&(identical(other.regularDeliveryMaxDays, regularDeliveryMaxDays) || other.regularDeliveryMaxDays == regularDeliveryMaxDays)&&(identical(other.fastDeliveryFee, fastDeliveryFee) || other.fastDeliveryFee == fastDeliveryFee)&&(identical(other.regularDeliveryFee, regularDeliveryFee) || other.regularDeliveryFee == regularDeliveryFee)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,sellerId,name,description,price,unit,stockQuantity,category,brand,minOrderQuantity,const DeepCollectionEquality().hash(_attributes),const DeepCollectionEquality().hash(_images),status,supportsFastDelivery,supportsRegularDelivery,sellerManagedFastDelivery,sellerCountryCode,reservedQuantity,soldQuantity,ratingAverage,ratingCount,sellerServiceLocation,fastDeliveryMinDays,fastDeliveryMaxDays,regularDeliveryMinDays,regularDeliveryMaxDays,fastDeliveryFee,regularDeliveryFee,createdAt,updatedAt]);
}

@override
String toString() {
    return 'Product(id: $id, sellerId: $sellerId, name: $name, description: $description, price: $price, unit: $unit, stockQuantity: $stockQuantity, category: $category, brand: $brand, minOrderQuantity: $minOrderQuantity, attributes: $attributes, images: $images, status: $status, supportsFastDelivery: $supportsFastDelivery, supportsRegularDelivery: $supportsRegularDelivery, sellerManagedFastDelivery: $sellerManagedFastDelivery, sellerCountryCode: $sellerCountryCode, reservedQuantity: $reservedQuantity, soldQuantity: $soldQuantity, ratingAverage: $ratingAverage, ratingCount: $ratingCount, sellerServiceLocation: $sellerServiceLocation, fastDeliveryMinDays: $fastDeliveryMinDays, fastDeliveryMaxDays: $fastDeliveryMaxDays, regularDeliveryMinDays: $regularDeliveryMinDays, regularDeliveryMaxDays: $regularDeliveryMaxDays, fastDeliveryFee: $fastDeliveryFee, regularDeliveryFee: $regularDeliveryFee, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String sellerId, String name, String description, double price, String unit,@JsonKey(fromJson: _parseInventoryInt) int stockQuantity, String category, String? brand,@JsonKey(fromJson: _parseMinOrderQuantity) int minOrderQuantity, Map<String, dynamic> attributes, List<ProductImage> images, String status, bool supportsFastDelivery, bool supportsRegularDelivery, bool sellerManagedFastDelivery, String? sellerCountryCode,@JsonKey(fromJson: _parseInventoryInt) int reservedQuantity,@JsonKey(fromJson: _parseInventoryInt) int soldQuantity, double ratingAverage, int ratingCount,@JsonKey(fromJson: _locationFromJson, toJson: _locationToJson) GeoLocation? sellerServiceLocation, int? fastDeliveryMinDays, int? fastDeliveryMaxDays, int? regularDeliveryMinDays, int? regularDeliveryMaxDays, double? fastDeliveryFee, double? regularDeliveryFee, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sellerId = null,Object? name = null,Object? description = null,Object? price = null,Object? unit = null,Object? stockQuantity = null,Object? category = null,Object? brand = freezed,Object? minOrderQuantity = null,Object? attributes = null,Object? images = null,Object? status = null,Object? supportsFastDelivery = null,Object? supportsRegularDelivery = null,Object? sellerManagedFastDelivery = null,Object? sellerCountryCode = freezed,Object? reservedQuantity = null,Object? soldQuantity = null,Object? ratingAverage = null,Object? ratingCount = null,Object? sellerServiceLocation = freezed,Object? fastDeliveryMinDays = freezed,Object? fastDeliveryMaxDays = freezed,Object? regularDeliveryMinDays = freezed,Object? regularDeliveryMaxDays = freezed,Object? fastDeliveryFee = freezed,Object? regularDeliveryFee = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,stockQuantity: null == stockQuantity ? _self.stockQuantity : stockQuantity // ignore: cast_nullable_to_non_nullable
as int,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,minOrderQuantity: null == minOrderQuantity ? _self.minOrderQuantity : minOrderQuantity // ignore: cast_nullable_to_non_nullable
as int,attributes: null == attributes ? _self._attributes : attributes // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<ProductImage>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,supportsFastDelivery: null == supportsFastDelivery ? _self.supportsFastDelivery : supportsFastDelivery // ignore: cast_nullable_to_non_nullable
as bool,supportsRegularDelivery: null == supportsRegularDelivery ? _self.supportsRegularDelivery : supportsRegularDelivery // ignore: cast_nullable_to_non_nullable
as bool,sellerManagedFastDelivery: null == sellerManagedFastDelivery ? _self.sellerManagedFastDelivery : sellerManagedFastDelivery // ignore: cast_nullable_to_non_nullable
as bool,sellerCountryCode: freezed == sellerCountryCode ? _self.sellerCountryCode : sellerCountryCode // ignore: cast_nullable_to_non_nullable
as String?,reservedQuantity: null == reservedQuantity ? _self.reservedQuantity : reservedQuantity // ignore: cast_nullable_to_non_nullable
as int,soldQuantity: null == soldQuantity ? _self.soldQuantity : soldQuantity // ignore: cast_nullable_to_non_nullable
as int,ratingAverage: null == ratingAverage ? _self.ratingAverage : ratingAverage // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,sellerServiceLocation: freezed == sellerServiceLocation ? _self.sellerServiceLocation : sellerServiceLocation // ignore: cast_nullable_to_non_nullable
as GeoLocation?,fastDeliveryMinDays: freezed == fastDeliveryMinDays ? _self.fastDeliveryMinDays : fastDeliveryMinDays // ignore: cast_nullable_to_non_nullable
as int?,fastDeliveryMaxDays: freezed == fastDeliveryMaxDays ? _self.fastDeliveryMaxDays : fastDeliveryMaxDays // ignore: cast_nullable_to_non_nullable
as int?,regularDeliveryMinDays: freezed == regularDeliveryMinDays ? _self.regularDeliveryMinDays : regularDeliveryMinDays // ignore: cast_nullable_to_non_nullable
as int?,regularDeliveryMaxDays: freezed == regularDeliveryMaxDays ? _self.regularDeliveryMaxDays : regularDeliveryMaxDays // ignore: cast_nullable_to_non_nullable
as int?,fastDeliveryFee: freezed == fastDeliveryFee ? _self.fastDeliveryFee : fastDeliveryFee // ignore: cast_nullable_to_non_nullable
as double?,regularDeliveryFee: freezed == regularDeliveryFee ? _self.regularDeliveryFee : regularDeliveryFee // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
