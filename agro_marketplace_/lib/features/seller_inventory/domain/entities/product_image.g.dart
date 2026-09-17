// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductImage _$ProductImageFromJson(Map<String, dynamic> json) =>
    _ProductImage(
      id: json['id'] as String,
      data: const BlobConverter().fromJson(json['data']),
      contentType: json['contentType'] as String,
      fileName: json['fileName'] as String,
      uploadedAt: const TimestampConverter().fromJson(json['uploadedAt']),
      isPrimary: json['isPrimary'] as bool? ?? false,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ProductImageToJson(_ProductImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'data': const BlobConverter().toJson(instance.data),
      'contentType': instance.contentType,
      'fileName': instance.fileName,
      'uploadedAt': const TimestampConverter().toJson(instance.uploadedAt),
      'isPrimary': instance.isPrimary,
      'displayOrder': instance.displayOrder,
    };
