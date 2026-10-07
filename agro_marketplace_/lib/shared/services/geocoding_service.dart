import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';

/// Structured address fields extracted from reverse-geocoding coordinates.
class GeocodedAddress {
  final String? line1;
  final String? line2;
  final String? landmark;
  final String? village;
  final String? taluka;
  final String? district;
  final String? state;
  final String? pincode;

  const GeocodedAddress({
    this.line1,
    this.line2,
    this.landmark,
    this.village,
    this.taluka,
    this.district,
    this.state,
    this.pincode,
  });

  bool get isEmpty =>
      (line1 == null || line1!.isEmpty) &&
      (line2 == null || line2!.isEmpty) &&
      (landmark == null || landmark!.isEmpty) &&
      (village == null || village!.isEmpty) &&
      (taluka == null || taluka!.isEmpty) &&
      (district == null || district!.isEmpty) &&
      (state == null || state!.isEmpty) &&
      (pincode == null || pincode!.isEmpty);

  bool get isNotEmpty => !isEmpty;

  @override
  String toString() {
    return 'GeocodedAddress(line1: $line1, line2: $line2, landmark: $landmark, '
        'village: $village, taluka: $taluka, district: $district, '
        'state: $state, pincode: $pincode)';
  }
}

/// Reverse geocoding service that converts GPS coordinates into structured
/// address components suitable for the app's address forms.
///
/// Implements dual-layer resolution:
/// 1. Native platform geocoding (via [geocoding] package)
/// 2. OpenStreetMap Nominatim reverse API fallback (if native geocoder fails or lacks services)
class GeocodingService {
  GeocodingService._();

  /// Reverse-geocodes given [latitude] and [longitude] into structured [GeocodedAddress].
  ///
  /// Returns `null` if resolution fails completely.
  static Future<GeocodedAddress?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    // 1. First attempt: Native device geocoding
    try {
      final geocoder = Geocoding();
      final isPresent = await geocoder.isPresent();
      if (isPresent) {
        final placemarks = await geocoder.placemarkFromCoordinates(
          latitude,
          longitude,
        );
        if (placemarks.isNotEmpty) {
          final parsed = _fromPlacemark(placemarks.first);
          if (parsed.isNotEmpty) {
            debugPrint('GeocodingService: Resolved via native geocoder: $parsed');
            return parsed;
          }
        }
      } else {
        debugPrint('GeocodingService: Native geocoder is not present, trying OSM fallback...');
      }
    } catch (e) {
      debugPrint('GeocodingService: Native geocoding failed ($e), trying OSM fallback...');
    }

    // 2. Second attempt: OpenStreetMap Nominatim reverse API fallback
    try {
      final fallbackAddress = await _getFromNominatim(latitude, longitude);
      if (fallbackAddress != null && fallbackAddress.isNotEmpty) {
        debugPrint('GeocodingService: Resolved via OSM Nominatim fallback: $fallbackAddress');
        return fallbackAddress;
      }
    } catch (e) {
      debugPrint('GeocodingService: OSM Nominatim fallback failed: $e');
    }

    return null;
  }

  /// Parses a native [Placemark] into [GeocodedAddress].
  static GeocodedAddress _fromPlacemark(Placemark place) {
    // Line 1: Street, road, or house/building name
    String? line1;
    final street = place.street?.trim();
    final thoroughfare = place.thoroughfare?.trim();
    final subThoroughfare = place.subThoroughfare?.trim();
    final name = place.name?.trim();

    if (street != null && street.isNotEmpty) {
      line1 = street;
    } else if (thoroughfare != null && thoroughfare.isNotEmpty) {
      if (subThoroughfare != null && subThoroughfare.isNotEmpty) {
        line1 = '$subThoroughfare, $thoroughfare';
      } else {
        line1 = thoroughfare;
      }
    } else if (name != null && name.isNotEmpty) {
      line1 = name;
    }

    // Line 2: Sub-locality / area / sector
    String? line2 = place.subLocality?.trim();
    if (line2 != null && line2.isEmpty) line2 = null;

    // Landmark: Placemark name if distinct from street and not purely a number
    String? landmark;
    if (name != null &&
        name.isNotEmpty &&
        name != line1 &&
        name != line2 &&
        int.tryParse(name) == null) {
      landmark = name;
    }

    // Village / Town / City
    String? village = place.locality?.trim();
    if (village == null || village.isEmpty) {
      village = place.subLocality?.trim();
    }

    // Taluka & District
    String? taluka;
    String? district;
    final subAdmin = place.subAdministrativeArea?.trim();
    final admin = place.administrativeArea?.trim();

    if (subAdmin != null && subAdmin.isNotEmpty) {
      district = subAdmin;
      // If locality is distinct from district, locality can serve as taluka/town
      if (place.locality != null &&
          place.locality!.trim().isNotEmpty &&
          place.locality!.trim() != subAdmin) {
        taluka = place.locality!.trim();
      }
    } else if (place.locality != null && place.locality!.trim().isNotEmpty) {
      district = place.locality!.trim();
    }

    final state = (admin != null && admin.isNotEmpty) ? admin : null;
    final pincode = _cleanPincode(place.postalCode);

    return GeocodedAddress(
      line1: line1,
      line2: line2,
      landmark: landmark,
      village: village,
      taluka: taluka,
      district: district,
      state: state,
      pincode: pincode,
    );
  }

  /// Queries OpenStreetMap Nominatim reverse geocode API as a reliable fallback.
  static Future<GeocodedAddress?> _getFromNominatim(
    double latitude,
    double longitude,
  ) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 6);

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=jsonv2&accept-language=en',
      );
      final request = await client.getUrl(uri);
      request.headers.set(
        'User-Agent',
        'AgroMarketplaceApp/1.0 (contact: support@agromarketplace.app)',
      );

      final response = await request.close().timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          final houseNumber = (address['house_number'] as String?)?.trim();
          final road = (address['road'] as String?)?.trim();
          final building = (address['building'] as String?)?.trim();

          String? line1;
          if (houseNumber != null && road != null) {
            line1 = '$houseNumber, $road';
          } else if (road != null) {
            line1 = road;
          } else if (building != null) {
            line1 = building;
          }

          final suburb = (address['suburb'] as String?)?.trim();
          final neighbourhood = (address['neighbourhood'] as String?)?.trim();
          final residential = (address['residential'] as String?)?.trim();
          final line2 = suburb ?? neighbourhood ?? residential;

          final village = ((address['village'] ??
                  address['town'] ??
                  address['city'] ??
                  address['municipality']) as String?)
              ?.trim();

          final taluka = ((address['taluk'] ??
                  address['tehsil'] ??
                  address['subdistrict']) as String?)
              ?.trim();

          final district = ((address['state_district'] ??
                  address['district'] ??
                  address['county']) as String?)
              ?.trim();

          final state = (address['state'] as String?)?.trim();
          final pincode = _cleanPincode(address['postcode'] as String?);

          return GeocodedAddress(
            line1: line1,
            line2: line2,
            village: village,
            taluka: taluka,
            district: district,
            state: state,
            pincode: pincode,
          );
        }
      }
    } finally {
      client.close();
    }
    return null;
  }

  /// Sanitizes pincode to extract standard digits (e.g. 6 digits for India).
  static String? _cleanPincode(String? raw) {
    if (raw == null) return null;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 6) {
      return digits.substring(0, 6);
    }
    return digits.isNotEmpty ? digits : raw.trim();
  }
}
