import 'package:equatable/equatable.dart';

/// Represents a physical address.
///
/// Used for stores, delivery addresses, and seller locations.
/// Designed for Indian rural/semi-urban addressing with support for
/// village, taluka, district hierarchy.
class Address extends Equatable {
  final String? line1;
  final String? line2;
  final String? landmark;
  final String? village;
  final String? taluka;
  final String? district;
  final String state;
  final String pincode;

  const Address({
    this.line1,
    this.line2,
    this.landmark,
    this.village,
    this.taluka,
    this.district,
    required this.state,
    required this.pincode,
  });

  /// Creates an [Address] from a Firestore map.
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      line1: map['line1'] as String?,
      line2: map['line2'] as String?,
      landmark: map['landmark'] as String?,
      village: map['village'] as String?,
      taluka: map['taluka'] as String?,
      district: map['district'] as String?,
      state: map['state'] as String? ?? '',
      pincode: map['pincode'] as String? ?? '',
    );
  }

  /// Converts to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      if (line1 != null) 'line1': line1,
      if (line2 != null) 'line2': line2,
      if (landmark != null) 'landmark': landmark,
      if (village != null) 'village': village,
      if (taluka != null) 'taluka': taluka,
      if (district != null) 'district': district,
      'state': state,
      'pincode': pincode,
    };
  }

  /// Human-readable display string.
  String get displayAddress {
    final parts = <String>[
      if (line1 != null && line1!.isNotEmpty) line1!,
      if (line2 != null && line2!.isNotEmpty) line2!,
      if (landmark != null && landmark!.isNotEmpty) 'Near $landmark',
      if (village != null && village!.isNotEmpty) village!,
      if (taluka != null && taluka!.isNotEmpty) taluka!,
      if (district != null && district!.isNotEmpty) district!,
      if (state.isNotEmpty) state,
      if (pincode.isNotEmpty) pincode,
    ];
    return parts.join(', ');
  }

  /// Short display (village/district + pincode).
  String get shortAddress {
    final location = village ?? taluka ?? district ?? state;
    return '$location - $pincode';
  }

  Address copyWith({
    String? line1,
    String? line2,
    String? landmark,
    String? village,
    String? taluka,
    String? district,
    String? state,
    String? pincode,
  }) {
    return Address(
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      landmark: landmark ?? this.landmark,
      village: village ?? this.village,
      taluka: taluka ?? this.taluka,
      district: district ?? this.district,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
    );
  }

  @override
  List<Object?> get props =>
      [line1, line2, landmark, village, taluka, district, state, pincode];
}
