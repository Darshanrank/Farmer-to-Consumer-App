// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {

 String get uid; String get email; String get role; bool get isEmailVerified; String? get displayName; String? get phone; String? get photoUrl; String? get businessName;/// Structured address stored as a map (see [DetailedAddress]).
/// Backward compatible: old plain-string values are auto-converted via [AddressJsonConverter].
@AddressJsonConverter() Map<String, dynamic>? get address; List<Map<String, dynamic>> get savedAddresses; bool get fastDeliveryEnabled; bool get regularDeliveryEnabled; Map<String, dynamic>? get deliveryOrigin; String? get deliveryCountryCode; int? get fastDeliveryMinDays; int? get fastDeliveryMaxDays; int? get regularDeliveryMinDays; int? get regularDeliveryMaxDays; double? get fastDeliveryFee; double? get regularDeliveryFee; String get status; DateTime? get createdAt; DateTime? get lastLoginAt;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppUser;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.uid, _this.uid) || other.uid == _this.uid)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.isEmailVerified, _this.isEmailVerified) || other.isEmailVerified == _this.isEmailVerified)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.photoUrl, _this.photoUrl) || other.photoUrl == _this.photoUrl)&&(identical(other.businessName, _this.businessName) || other.businessName == _this.businessName)&&const DeepCollectionEquality().equals(other.address, _this.address)&&const DeepCollectionEquality().equals(other.savedAddresses, _this.savedAddresses)&&(identical(other.fastDeliveryEnabled, _this.fastDeliveryEnabled) || other.fastDeliveryEnabled == _this.fastDeliveryEnabled)&&(identical(other.regularDeliveryEnabled, _this.regularDeliveryEnabled) || other.regularDeliveryEnabled == _this.regularDeliveryEnabled)&&const DeepCollectionEquality().equals(other.deliveryOrigin, _this.deliveryOrigin)&&(identical(other.deliveryCountryCode, _this.deliveryCountryCode) || other.deliveryCountryCode == _this.deliveryCountryCode)&&(identical(other.fastDeliveryMinDays, _this.fastDeliveryMinDays) || other.fastDeliveryMinDays == _this.fastDeliveryMinDays)&&(identical(other.fastDeliveryMaxDays, _this.fastDeliveryMaxDays) || other.fastDeliveryMaxDays == _this.fastDeliveryMaxDays)&&(identical(other.regularDeliveryMinDays, _this.regularDeliveryMinDays) || other.regularDeliveryMinDays == _this.regularDeliveryMinDays)&&(identical(other.regularDeliveryMaxDays, _this.regularDeliveryMaxDays) || other.regularDeliveryMaxDays == _this.regularDeliveryMaxDays)&&(identical(other.fastDeliveryFee, _this.fastDeliveryFee) || other.fastDeliveryFee == _this.fastDeliveryFee)&&(identical(other.regularDeliveryFee, _this.regularDeliveryFee) || other.regularDeliveryFee == _this.regularDeliveryFee)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.lastLoginAt, _this.lastLoginAt) || other.lastLoginAt == _this.lastLoginAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppUser;
  return Object.hashAll([runtimeType,_this.uid,_this.email,_this.role,_this.isEmailVerified,_this.displayName,_this.phone,_this.photoUrl,_this.businessName,const DeepCollectionEquality().hash(_this.address),const DeepCollectionEquality().hash(_this.savedAddresses),_this.fastDeliveryEnabled,_this.regularDeliveryEnabled,const DeepCollectionEquality().hash(_this.deliveryOrigin),_this.deliveryCountryCode,_this.fastDeliveryMinDays,_this.fastDeliveryMaxDays,_this.regularDeliveryMinDays,_this.regularDeliveryMaxDays,_this.fastDeliveryFee,_this.regularDeliveryFee,_this.status,_this.createdAt,_this.lastLoginAt]);
}

@override
String toString() {
  final _this = this as AppUser;
  return 'AppUser(uid: ${_this.uid}, email: ${_this.email}, role: ${_this.role}, isEmailVerified: ${_this.isEmailVerified}, displayName: ${_this.displayName}, phone: ${_this.phone}, photoUrl: ${_this.photoUrl}, businessName: ${_this.businessName}, address: ${_this.address}, savedAddresses: ${_this.savedAddresses}, fastDeliveryEnabled: ${_this.fastDeliveryEnabled}, regularDeliveryEnabled: ${_this.regularDeliveryEnabled}, deliveryOrigin: ${_this.deliveryOrigin}, deliveryCountryCode: ${_this.deliveryCountryCode}, fastDeliveryMinDays: ${_this.fastDeliveryMinDays}, fastDeliveryMaxDays: ${_this.fastDeliveryMaxDays}, regularDeliveryMinDays: ${_this.regularDeliveryMinDays}, regularDeliveryMaxDays: ${_this.regularDeliveryMaxDays}, fastDeliveryFee: ${_this.fastDeliveryFee}, regularDeliveryFee: ${_this.regularDeliveryFee}, status: ${_this.status}, createdAt: ${_this.createdAt}, lastLoginAt: ${_this.lastLoginAt})';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String uid, String email, String role, bool isEmailVerified, String? displayName, String? phone, String? photoUrl, String? businessName,@AddressJsonConverter() Map<String, dynamic>? address, List<Map<String, dynamic>> savedAddresses, bool fastDeliveryEnabled, bool regularDeliveryEnabled, Map<String, dynamic>? deliveryOrigin, String? deliveryCountryCode, int? fastDeliveryMinDays, int? fastDeliveryMaxDays, int? regularDeliveryMinDays, int? regularDeliveryMaxDays, double? fastDeliveryFee, double? regularDeliveryFee, String status, DateTime? createdAt, DateTime? lastLoginAt
});




}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? email = null,Object? role = null,Object? isEmailVerified = null,Object? displayName = freezed,Object? phone = freezed,Object? photoUrl = freezed,Object? businessName = freezed,Object? address = freezed,Object? savedAddresses = null,Object? fastDeliveryEnabled = null,Object? regularDeliveryEnabled = null,Object? deliveryOrigin = freezed,Object? deliveryCountryCode = freezed,Object? fastDeliveryMinDays = freezed,Object? fastDeliveryMaxDays = freezed,Object? regularDeliveryMinDays = freezed,Object? regularDeliveryMaxDays = freezed,Object? fastDeliveryFee = freezed,Object? regularDeliveryFee = freezed,Object? status = null,Object? createdAt = freezed,Object? lastLoginAt = freezed,}) {
  return _then(AppUser(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,businessName: freezed == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,savedAddresses: null == savedAddresses ? _self.savedAddresses : savedAddresses // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,fastDeliveryEnabled: null == fastDeliveryEnabled ? _self.fastDeliveryEnabled : fastDeliveryEnabled // ignore: cast_nullable_to_non_nullable
as bool,regularDeliveryEnabled: null == regularDeliveryEnabled ? _self.regularDeliveryEnabled : regularDeliveryEnabled // ignore: cast_nullable_to_non_nullable
as bool,deliveryOrigin: freezed == deliveryOrigin ? _self.deliveryOrigin : deliveryOrigin // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,deliveryCountryCode: freezed == deliveryCountryCode ? _self.deliveryCountryCode : deliveryCountryCode // ignore: cast_nullable_to_non_nullable
as String?,fastDeliveryMinDays: freezed == fastDeliveryMinDays ? _self.fastDeliveryMinDays : fastDeliveryMinDays // ignore: cast_nullable_to_non_nullable
as int?,fastDeliveryMaxDays: freezed == fastDeliveryMaxDays ? _self.fastDeliveryMaxDays : fastDeliveryMaxDays // ignore: cast_nullable_to_non_nullable
as int?,regularDeliveryMinDays: freezed == regularDeliveryMinDays ? _self.regularDeliveryMinDays : regularDeliveryMinDays // ignore: cast_nullable_to_non_nullable
as int?,regularDeliveryMaxDays: freezed == regularDeliveryMaxDays ? _self.regularDeliveryMaxDays : regularDeliveryMaxDays // ignore: cast_nullable_to_non_nullable
as int?,fastDeliveryFee: freezed == fastDeliveryFee ? _self.fastDeliveryFee : fastDeliveryFee // ignore: cast_nullable_to_non_nullable
as double?,regularDeliveryFee: freezed == regularDeliveryFee ? _self.regularDeliveryFee : regularDeliveryFee // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String email,  String role,  bool isEmailVerified,  String? displayName,  String? phone,  String? photoUrl,  String? businessName, @AddressJsonConverter()  Map<String, dynamic>? address,  List<Map<String, dynamic>> savedAddresses,  bool fastDeliveryEnabled,  bool regularDeliveryEnabled,  Map<String, dynamic>? deliveryOrigin,  String? deliveryCountryCode,  int? fastDeliveryMinDays,  int? fastDeliveryMaxDays,  int? regularDeliveryMinDays,  int? regularDeliveryMaxDays,  double? fastDeliveryFee,  double? regularDeliveryFee,  String status,  DateTime? createdAt,  DateTime? lastLoginAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.uid,_that.email,_that.role,_that.isEmailVerified,_that.displayName,_that.phone,_that.photoUrl,_that.businessName,_that.address,_that.savedAddresses,_that.fastDeliveryEnabled,_that.regularDeliveryEnabled,_that.deliveryOrigin,_that.deliveryCountryCode,_that.fastDeliveryMinDays,_that.fastDeliveryMaxDays,_that.regularDeliveryMinDays,_that.regularDeliveryMaxDays,_that.fastDeliveryFee,_that.regularDeliveryFee,_that.status,_that.createdAt,_that.lastLoginAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String email,  String role,  bool isEmailVerified,  String? displayName,  String? phone,  String? photoUrl,  String? businessName, @AddressJsonConverter()  Map<String, dynamic>? address,  List<Map<String, dynamic>> savedAddresses,  bool fastDeliveryEnabled,  bool regularDeliveryEnabled,  Map<String, dynamic>? deliveryOrigin,  String? deliveryCountryCode,  int? fastDeliveryMinDays,  int? fastDeliveryMaxDays,  int? regularDeliveryMinDays,  int? regularDeliveryMaxDays,  double? fastDeliveryFee,  double? regularDeliveryFee,  String status,  DateTime? createdAt,  DateTime? lastLoginAt)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.uid,_that.email,_that.role,_that.isEmailVerified,_that.displayName,_that.phone,_that.photoUrl,_that.businessName,_that.address,_that.savedAddresses,_that.fastDeliveryEnabled,_that.regularDeliveryEnabled,_that.deliveryOrigin,_that.deliveryCountryCode,_that.fastDeliveryMinDays,_that.fastDeliveryMaxDays,_that.regularDeliveryMinDays,_that.regularDeliveryMaxDays,_that.fastDeliveryFee,_that.regularDeliveryFee,_that.status,_that.createdAt,_that.lastLoginAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String email,  String role,  bool isEmailVerified,  String? displayName,  String? phone,  String? photoUrl,  String? businessName, @AddressJsonConverter()  Map<String, dynamic>? address,  List<Map<String, dynamic>> savedAddresses,  bool fastDeliveryEnabled,  bool regularDeliveryEnabled,  Map<String, dynamic>? deliveryOrigin,  String? deliveryCountryCode,  int? fastDeliveryMinDays,  int? fastDeliveryMaxDays,  int? regularDeliveryMinDays,  int? regularDeliveryMaxDays,  double? fastDeliveryFee,  double? regularDeliveryFee,  String status,  DateTime? createdAt,  DateTime? lastLoginAt)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.uid,_that.email,_that.role,_that.isEmailVerified,_that.displayName,_that.phone,_that.photoUrl,_that.businessName,_that.address,_that.savedAddresses,_that.fastDeliveryEnabled,_that.regularDeliveryEnabled,_that.deliveryOrigin,_that.deliveryCountryCode,_that.fastDeliveryMinDays,_that.fastDeliveryMaxDays,_that.regularDeliveryMinDays,_that.regularDeliveryMaxDays,_that.fastDeliveryFee,_that.regularDeliveryFee,_that.status,_that.createdAt,_that.lastLoginAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser extends AppUser {
  const _AppUser({required this.uid, required this.email, this.role = 'buyer', this.isEmailVerified = false, this.displayName, this.phone, this.photoUrl, this.businessName, @AddressJsonConverter()  Map<String, dynamic>? address,  List<Map<String, dynamic>> savedAddresses = const <Map<String, dynamic>>[], this.fastDeliveryEnabled = false, this.regularDeliveryEnabled = false,  Map<String, dynamic>? deliveryOrigin, this.deliveryCountryCode, this.fastDeliveryMinDays, this.fastDeliveryMaxDays, this.regularDeliveryMinDays, this.regularDeliveryMaxDays, this.fastDeliveryFee, this.regularDeliveryFee, this.status = 'active', this.createdAt, this.lastLoginAt}): _address = address,_savedAddresses = savedAddresses,_deliveryOrigin = deliveryOrigin,super._();
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override final  String uid;
@override final  String email;
@override@JsonKey() final  String role;
@override@JsonKey() final  bool isEmailVerified;
@override final  String? displayName;
@override final  String? phone;
@override final  String? photoUrl;
@override final  String? businessName;
/// Structured address stored as a map (see [DetailedAddress]).
/// Backward compatible: old plain-string values are auto-converted via [AddressJsonConverter].
 final  Map<String, dynamic>? _address;
/// Structured address stored as a map (see [DetailedAddress]).
/// Backward compatible: old plain-string values are auto-converted via [AddressJsonConverter].
@override@AddressJsonConverter() Map<String, dynamic>? get address {
  final value = _address;
  if (value == null) return null;
  if (_address is EqualUnmodifiableMapView) return _address;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<Map<String, dynamic>> _savedAddresses;
@override@JsonKey() List<Map<String, dynamic>> get savedAddresses {
  if (_savedAddresses is EqualUnmodifiableListView) return _savedAddresses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_savedAddresses);
}

@override@JsonKey() final  bool fastDeliveryEnabled;
@override@JsonKey() final  bool regularDeliveryEnabled;
 final  Map<String, dynamic>? _deliveryOrigin;
@override Map<String, dynamic>? get deliveryOrigin {
  final value = _deliveryOrigin;
  if (value == null) return null;
  if (_deliveryOrigin is EqualUnmodifiableMapView) return _deliveryOrigin;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? deliveryCountryCode;
@override final  int? fastDeliveryMinDays;
@override final  int? fastDeliveryMaxDays;
@override final  int? regularDeliveryMinDays;
@override final  int? regularDeliveryMaxDays;
@override final  double? fastDeliveryFee;
@override final  double? regularDeliveryFee;
@override@JsonKey() final  String status;
@override final  DateTime? createdAt;
@override final  DateTime? lastLoginAt;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&const DeepCollectionEquality().equals(other.address, _address)&&const DeepCollectionEquality().equals(other.savedAddresses, _savedAddresses)&&(identical(other.fastDeliveryEnabled, fastDeliveryEnabled) || other.fastDeliveryEnabled == fastDeliveryEnabled)&&(identical(other.regularDeliveryEnabled, regularDeliveryEnabled) || other.regularDeliveryEnabled == regularDeliveryEnabled)&&const DeepCollectionEquality().equals(other.deliveryOrigin, _deliveryOrigin)&&(identical(other.deliveryCountryCode, deliveryCountryCode) || other.deliveryCountryCode == deliveryCountryCode)&&(identical(other.fastDeliveryMinDays, fastDeliveryMinDays) || other.fastDeliveryMinDays == fastDeliveryMinDays)&&(identical(other.fastDeliveryMaxDays, fastDeliveryMaxDays) || other.fastDeliveryMaxDays == fastDeliveryMaxDays)&&(identical(other.regularDeliveryMinDays, regularDeliveryMinDays) || other.regularDeliveryMinDays == regularDeliveryMinDays)&&(identical(other.regularDeliveryMaxDays, regularDeliveryMaxDays) || other.regularDeliveryMaxDays == regularDeliveryMaxDays)&&(identical(other.fastDeliveryFee, fastDeliveryFee) || other.fastDeliveryFee == fastDeliveryFee)&&(identical(other.regularDeliveryFee, regularDeliveryFee) || other.regularDeliveryFee == regularDeliveryFee)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,uid,email,role,isEmailVerified,displayName,phone,photoUrl,businessName,const DeepCollectionEquality().hash(_address),const DeepCollectionEquality().hash(_savedAddresses),fastDeliveryEnabled,regularDeliveryEnabled,const DeepCollectionEquality().hash(_deliveryOrigin),deliveryCountryCode,fastDeliveryMinDays,fastDeliveryMaxDays,regularDeliveryMinDays,regularDeliveryMaxDays,fastDeliveryFee,regularDeliveryFee,status,createdAt,lastLoginAt]);
}

@override
String toString() {
    return 'AppUser(uid: $uid, email: $email, role: $role, isEmailVerified: $isEmailVerified, displayName: $displayName, phone: $phone, photoUrl: $photoUrl, businessName: $businessName, address: $address, savedAddresses: $savedAddresses, fastDeliveryEnabled: $fastDeliveryEnabled, regularDeliveryEnabled: $regularDeliveryEnabled, deliveryOrigin: $deliveryOrigin, deliveryCountryCode: $deliveryCountryCode, fastDeliveryMinDays: $fastDeliveryMinDays, fastDeliveryMaxDays: $fastDeliveryMaxDays, regularDeliveryMinDays: $regularDeliveryMinDays, regularDeliveryMaxDays: $regularDeliveryMaxDays, fastDeliveryFee: $fastDeliveryFee, regularDeliveryFee: $regularDeliveryFee, status: $status, createdAt: $createdAt, lastLoginAt: $lastLoginAt)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String role, bool isEmailVerified, String? displayName, String? phone, String? photoUrl, String? businessName,@AddressJsonConverter() Map<String, dynamic>? address, List<Map<String, dynamic>> savedAddresses, bool fastDeliveryEnabled, bool regularDeliveryEnabled, Map<String, dynamic>? deliveryOrigin, String? deliveryCountryCode, int? fastDeliveryMinDays, int? fastDeliveryMaxDays, int? regularDeliveryMinDays, int? regularDeliveryMaxDays, double? fastDeliveryFee, double? regularDeliveryFee, String status, DateTime? createdAt, DateTime? lastLoginAt
});




}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? role = null,Object? isEmailVerified = null,Object? displayName = freezed,Object? phone = freezed,Object? photoUrl = freezed,Object? businessName = freezed,Object? address = freezed,Object? savedAddresses = null,Object? fastDeliveryEnabled = null,Object? regularDeliveryEnabled = null,Object? deliveryOrigin = freezed,Object? deliveryCountryCode = freezed,Object? fastDeliveryMinDays = freezed,Object? fastDeliveryMaxDays = freezed,Object? regularDeliveryMinDays = freezed,Object? regularDeliveryMaxDays = freezed,Object? fastDeliveryFee = freezed,Object? regularDeliveryFee = freezed,Object? status = null,Object? createdAt = freezed,Object? lastLoginAt = freezed,}) {
  return _then(_AppUser(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,businessName: freezed == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self._address : address // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,savedAddresses: null == savedAddresses ? _self._savedAddresses : savedAddresses // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,fastDeliveryEnabled: null == fastDeliveryEnabled ? _self.fastDeliveryEnabled : fastDeliveryEnabled // ignore: cast_nullable_to_non_nullable
as bool,regularDeliveryEnabled: null == regularDeliveryEnabled ? _self.regularDeliveryEnabled : regularDeliveryEnabled // ignore: cast_nullable_to_non_nullable
as bool,deliveryOrigin: freezed == deliveryOrigin ? _self._deliveryOrigin : deliveryOrigin // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,deliveryCountryCode: freezed == deliveryCountryCode ? _self.deliveryCountryCode : deliveryCountryCode // ignore: cast_nullable_to_non_nullable
as String?,fastDeliveryMinDays: freezed == fastDeliveryMinDays ? _self.fastDeliveryMinDays : fastDeliveryMinDays // ignore: cast_nullable_to_non_nullable
as int?,fastDeliveryMaxDays: freezed == fastDeliveryMaxDays ? _self.fastDeliveryMaxDays : fastDeliveryMaxDays // ignore: cast_nullable_to_non_nullable
as int?,regularDeliveryMinDays: freezed == regularDeliveryMinDays ? _self.regularDeliveryMinDays : regularDeliveryMinDays // ignore: cast_nullable_to_non_nullable
as int?,regularDeliveryMaxDays: freezed == regularDeliveryMaxDays ? _self.regularDeliveryMaxDays : regularDeliveryMaxDays // ignore: cast_nullable_to_non_nullable
as int?,fastDeliveryFee: freezed == fastDeliveryFee ? _self.fastDeliveryFee : fastDeliveryFee // ignore: cast_nullable_to_non_nullable
as double?,regularDeliveryFee: freezed == regularDeliveryFee ? _self.regularDeliveryFee : regularDeliveryFee // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
