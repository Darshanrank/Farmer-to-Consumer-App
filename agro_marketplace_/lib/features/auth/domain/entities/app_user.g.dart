// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  uid: json['uid'] as String,
  email: json['email'] as String,
  role: json['role'] as String? ?? 'buyer',
  isEmailVerified: json['isEmailVerified'] as bool? ?? false,
  displayName: json['displayName'] as String?,
  phone: json['phone'] as String?,
  photoUrl: json['photoUrl'] as String?,
  businessName: json['businessName'] as String?,
  address: const AddressJsonConverter().fromJson(json['address']),
  savedAddresses:
      (json['savedAddresses'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <Map<String, dynamic>>[],
  fastDeliveryEnabled: json['fastDeliveryEnabled'] as bool? ?? false,
  regularDeliveryEnabled: json['regularDeliveryEnabled'] as bool? ?? false,
  deliveryOrigin: json['deliveryOrigin'] as Map<String, dynamic>?,
  deliveryCountryCode: json['deliveryCountryCode'] as String?,
  fastDeliveryMinDays: (json['fastDeliveryMinDays'] as num?)?.toInt(),
  fastDeliveryMaxDays: (json['fastDeliveryMaxDays'] as num?)?.toInt(),
  regularDeliveryMinDays: (json['regularDeliveryMinDays'] as num?)?.toInt(),
  regularDeliveryMaxDays: (json['regularDeliveryMaxDays'] as num?)?.toInt(),
  fastDeliveryFee: (json['fastDeliveryFee'] as num?)?.toDouble(),
  regularDeliveryFee: (json['regularDeliveryFee'] as num?)?.toDouble(),
  status: json['status'] as String? ?? 'active',
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'role': instance.role,
  'isEmailVerified': instance.isEmailVerified,
  'displayName': instance.displayName,
  'phone': instance.phone,
  'photoUrl': instance.photoUrl,
  'businessName': instance.businessName,
  'address': const AddressJsonConverter().toJson(instance.address),
  'savedAddresses': instance.savedAddresses,
  'fastDeliveryEnabled': instance.fastDeliveryEnabled,
  'regularDeliveryEnabled': instance.regularDeliveryEnabled,
  'deliveryOrigin': instance.deliveryOrigin,
  'deliveryCountryCode': instance.deliveryCountryCode,
  'fastDeliveryMinDays': instance.fastDeliveryMinDays,
  'fastDeliveryMaxDays': instance.fastDeliveryMaxDays,
  'regularDeliveryMinDays': instance.regularDeliveryMinDays,
  'regularDeliveryMaxDays': instance.regularDeliveryMaxDays,
  'fastDeliveryFee': instance.fastDeliveryFee,
  'regularDeliveryFee': instance.regularDeliveryFee,
  'status': instance.status,
  'createdAt': instance.createdAt?.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
};
