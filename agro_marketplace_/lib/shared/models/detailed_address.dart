import 'package:equatable/equatable.dart';

import 'address.dart';
import 'location.dart';

/// Represents a complete address with optional geographic coordinates.
///
/// Composes [Address] (structured postal address) with an optional
/// [GeoLocation] (latitude, longitude, geohash) so that every address
/// can support proximity-based queries and filtering.
///
/// Designed for backward compatibility: [fromMap] handles both the legacy
/// plain-string format and the new structured map format.
class DetailedAddress extends Equatable {
  final Address address;
  final GeoLocation? location;

  const DetailedAddress({
    required this.address,
    this.location,
  });

  /// Creates a [DetailedAddress] from a Firestore map.
  ///
  /// Handles backward compatibility:
  /// - If [map] contains a `'location'` key, it's treated as the new format.
  /// - The `'address'` sub-map contains the structured postal fields.
  factory DetailedAddress.fromMap(Map<String, dynamic> map) {
    final address = Address.fromMap(map);
    final locationData = map['location'] as Map<String, dynamic>?;

    return DetailedAddress(
      address: address,
      location: locationData != null ? GeoLocation.fromMap(locationData) : null,
    );
  }

  /// Creates a [DetailedAddress] from a legacy plain string.
  ///
  /// Used for backward compatibility with old Firestore documents
  /// that stored address as a single string field.
  factory DetailedAddress.fromString(String addressString) {
    return DetailedAddress(
      address: Address(
        line1: addressString,
        state: '',
        pincode: '',
      ),
    );
  }

  /// Converts to a Firestore-compatible map.
  ///
  /// The address fields are stored at the top level alongside
  /// an optional nested `location` map for geo-coordinates.
  Map<String, dynamic> toMap() {
    return {
      ...address.toMap(),
      if (location != null) 'location': location!.toMap(),
    };
  }

  /// Whether this address has valid geographic coordinates.
  bool get hasLocation => location != null && location!.isValid;

  /// Human-readable display string (delegates to [Address.displayAddress]).
  String get displayAddress => address.displayAddress;

  /// Short display (delegates to [Address.shortAddress]).
  String get shortAddress => address.shortAddress;

  DetailedAddress copyWith({
    Address? address,
    GeoLocation? location,
  }) {
    return DetailedAddress(
      address: address ?? this.address,
      location: location ?? this.location,
    );
  }

  @override
  List<Object?> get props => [address, location];

  @override
  String toString() =>
      'DetailedAddress(${address.displayAddress}, location: $location)';
}
