import 'package:equatable/equatable.dart';

/// Represents a geographic location with geohash support.
///
/// Used for store locations and nearby seller discovery.
/// Geohash enables Firestore-compatible proximity queries.
class GeoLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String? geohash;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
    this.geohash,
  });

  /// Creates a [GeoLocation] from a Firestore map.
  factory GeoLocation.fromMap(Map<String, dynamic> map) {
    return GeoLocation(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      geohash: map['geohash'] as String?,
    );
  }

  /// Converts to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (geohash != null) 'geohash': geohash,
    };
  }

  /// Whether this location has valid coordinates.
  bool get isValid =>
      latitude >= -90 && latitude <= 90 &&
      longitude >= -180 && longitude <= 180;

  GeoLocation copyWith({
    double? latitude,
    double? longitude,
    String? geohash,
  }) {
    return GeoLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, geohash];

  @override
  String toString() => 'GeoLocation($latitude, $longitude, geohash: $geohash)';
}
