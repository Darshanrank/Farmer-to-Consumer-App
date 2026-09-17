import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'dart:convert';

part 'product_image.freezed.dart';
part 'product_image.g.dart';

class BlobConverter implements JsonConverter<Uint8List, dynamic> {
  const BlobConverter();
  
  @override
  Uint8List fromJson(dynamic json) {
    if (json is Blob) return json.bytes;
    if (json is String) return base64Decode(json);
    if (json is List<dynamic>) return Uint8List.fromList(json.cast<int>());
    return Uint8List(0);
  }
  
  @override
  dynamic toJson(Uint8List object) => Blob(object);
}

class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();
  
  @override
  DateTime? fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.tryParse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return null;
  }
  
  @override
  dynamic toJson(DateTime? object) => object == null ? null : Timestamp.fromDate(object);
}

@freezed
abstract class ProductImage with _$ProductImage {
  const factory ProductImage({
    required String id,
    @BlobConverter() required Uint8List data,
    required String contentType,
    required String fileName,
    @TimestampConverter() DateTime? uploadedAt,
    @Default(false) bool isPrimary,
    @Default(0) int displayOrder,
  }) = _ProductImage;

  factory ProductImage.fromJson(Map<String, dynamic> json) => _$ProductImageFromJson(json);
}
