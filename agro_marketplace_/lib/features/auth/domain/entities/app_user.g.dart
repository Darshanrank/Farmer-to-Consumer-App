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
  'status': instance.status,
  'createdAt': instance.createdAt?.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
};
