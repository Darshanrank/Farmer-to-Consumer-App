// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seller_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SellerOrder {

 String get id; String get parentOrderId; String get buyerId; String get sellerId; List<CartItem> get items; double get totalAmount; String get status; String get shippingAddress; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of SellerOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SellerOrderCopyWith<SellerOrder> get copyWith => _$SellerOrderCopyWithImpl<SellerOrder>(this as SellerOrder, _$identity);

  /// Serializes this SellerOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SellerOrder;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SellerOrder&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.parentOrderId, _this.parentOrderId) || other.parentOrderId == _this.parentOrderId)&&(identical(other.buyerId, _this.buyerId) || other.buyerId == _this.buyerId)&&(identical(other.sellerId, _this.sellerId) || other.sellerId == _this.sellerId)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.totalAmount, _this.totalAmount) || other.totalAmount == _this.totalAmount)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.shippingAddress, _this.shippingAddress) || other.shippingAddress == _this.shippingAddress)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SellerOrder;
  return Object.hash(runtimeType,_this.id,_this.parentOrderId,_this.buyerId,_this.sellerId,const DeepCollectionEquality().hash(_this.items),_this.totalAmount,_this.status,_this.shippingAddress,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as SellerOrder;
  return 'SellerOrder(id: ${_this.id}, parentOrderId: ${_this.parentOrderId}, buyerId: ${_this.buyerId}, sellerId: ${_this.sellerId}, items: ${_this.items}, totalAmount: ${_this.totalAmount}, status: ${_this.status}, shippingAddress: ${_this.shippingAddress}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $SellerOrderCopyWith<$Res>  {
  factory $SellerOrderCopyWith(SellerOrder value, $Res Function(SellerOrder) _then) = _$SellerOrderCopyWithImpl;
@useResult
$Res call({
 String id, String parentOrderId, String buyerId, String sellerId, List<CartItem> items, double totalAmount, String status, String shippingAddress, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$SellerOrderCopyWithImpl<$Res>
    implements $SellerOrderCopyWith<$Res> {
  _$SellerOrderCopyWithImpl(this._self, this._then);

  final SellerOrder _self;
  final $Res Function(SellerOrder) _then;

/// Create a copy of SellerOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? parentOrderId = null,Object? buyerId = null,Object? sellerId = null,Object? items = null,Object? totalAmount = null,Object? status = null,Object? shippingAddress = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(SellerOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentOrderId: null == parentOrderId ? _self.parentOrderId : parentOrderId // ignore: cast_nullable_to_non_nullable
as String,buyerId: null == buyerId ? _self.buyerId : buyerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CartItem>,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,shippingAddress: null == shippingAddress ? _self.shippingAddress : shippingAddress // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SellerOrder].
extension SellerOrderPatterns on SellerOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SellerOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SellerOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SellerOrder value)  $default,){
final _that = this;
switch (_that) {
case _SellerOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SellerOrder value)?  $default,){
final _that = this;
switch (_that) {
case _SellerOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String parentOrderId,  String buyerId,  String sellerId,  List<CartItem> items,  double totalAmount,  String status,  String shippingAddress,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SellerOrder() when $default != null:
return $default(_that.id,_that.parentOrderId,_that.buyerId,_that.sellerId,_that.items,_that.totalAmount,_that.status,_that.shippingAddress,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String parentOrderId,  String buyerId,  String sellerId,  List<CartItem> items,  double totalAmount,  String status,  String shippingAddress,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SellerOrder():
return $default(_that.id,_that.parentOrderId,_that.buyerId,_that.sellerId,_that.items,_that.totalAmount,_that.status,_that.shippingAddress,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String parentOrderId,  String buyerId,  String sellerId,  List<CartItem> items,  double totalAmount,  String status,  String shippingAddress,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SellerOrder() when $default != null:
return $default(_that.id,_that.parentOrderId,_that.buyerId,_that.sellerId,_that.items,_that.totalAmount,_that.status,_that.shippingAddress,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SellerOrder extends SellerOrder {
  const _SellerOrder({required this.id, required this.parentOrderId, required this.buyerId, required this.sellerId, required  List<CartItem> items, required this.totalAmount, required this.status, required this.shippingAddress, this.createdAt, this.updatedAt}): _items = items,super._();
  factory _SellerOrder.fromJson(Map<String, dynamic> json) => _$SellerOrderFromJson(json);

@override final  String id;
@override final  String parentOrderId;
@override final  String buyerId;
@override final  String sellerId;
 final  List<CartItem> _items;
@override List<CartItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  double totalAmount;
@override final  String status;
@override final  String shippingAddress;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of SellerOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SellerOrderCopyWith<_SellerOrder> get copyWith => __$SellerOrderCopyWithImpl<_SellerOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SellerOrderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SellerOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.parentOrderId, parentOrderId) || other.parentOrderId == parentOrderId)&&(identical(other.buyerId, buyerId) || other.buyerId == buyerId)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.shippingAddress, shippingAddress) || other.shippingAddress == shippingAddress)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,parentOrderId,buyerId,sellerId,const DeepCollectionEquality().hash(_items),totalAmount,status,shippingAddress,createdAt,updatedAt);
}

@override
String toString() {
    return 'SellerOrder(id: $id, parentOrderId: $parentOrderId, buyerId: $buyerId, sellerId: $sellerId, items: $items, totalAmount: $totalAmount, status: $status, shippingAddress: $shippingAddress, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SellerOrderCopyWith<$Res> implements $SellerOrderCopyWith<$Res> {
  factory _$SellerOrderCopyWith(_SellerOrder value, $Res Function(_SellerOrder) _then) = __$SellerOrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String parentOrderId, String buyerId, String sellerId, List<CartItem> items, double totalAmount, String status, String shippingAddress, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$SellerOrderCopyWithImpl<$Res>
    implements _$SellerOrderCopyWith<$Res> {
  __$SellerOrderCopyWithImpl(this._self, this._then);

  final _SellerOrder _self;
  final $Res Function(_SellerOrder) _then;

/// Create a copy of SellerOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? parentOrderId = null,Object? buyerId = null,Object? sellerId = null,Object? items = null,Object? totalAmount = null,Object? status = null,Object? shippingAddress = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_SellerOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentOrderId: null == parentOrderId ? _self.parentOrderId : parentOrderId // ignore: cast_nullable_to_non_nullable
as String,buyerId: null == buyerId ? _self.buyerId : buyerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CartItem>,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,shippingAddress: null == shippingAddress ? _self.shippingAddress : shippingAddress // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
