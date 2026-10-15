import 'package:flutter_test/flutter_test.dart';

import 'package:agro_marketplace/core/validation/delivery_address_validator.dart';
import 'package:agro_marketplace/shared/models/address.dart';
import 'package:agro_marketplace/shared/models/detailed_address.dart';
import 'package:agro_marketplace/shared/models/location.dart';

DetailedAddress address({
  String recipient = 'Asha Patel',
  String phone = '9876543210',
  String line1 = '1 Market Road',
  String city = 'Ahmedabad',
  String state = 'Gujarat',
  String pincode = '380001',
  String? country = 'in',
  GeoLocation? location,
}) {
  return DetailedAddress(
    recipientName: recipient,
    phoneNumber: phone,
    address: Address(
      line1: line1,
      city: city,
      state: state,
      pincode: pincode,
      countryCode: country,
    ),
    location: location,
  );
}

void main() {
  test('rejects incomplete delivery addresses', () {
    final result = DeliveryAddressValidator.validate(address(line1: ''));
    expect(result.failure, DeliveryAddressValidationFailure.addressLineMissing);
  });

  test('rejects malformed coordinates when provided', () {
    final result = DeliveryAddressValidator.validate(
      address(location: const GeoLocation(latitude: 91, longitude: 72)),
    );
    expect(result.failure, DeliveryAddressValidationFailure.coordinatesInvalid);
  });

  test('rejects missing country code', () {
    final result = DeliveryAddressValidator.validate(address(country: null));
    expect(result.failure, DeliveryAddressValidationFailure.countryCodeMissing);
  });

  test('accepts a valid saved address with optional coordinates', () {
    final result = DeliveryAddressValidator.validate(
      address(
        location: const GeoLocation(latitude: 23.0225, longitude: 72.5714),
      ),
    );
    expect(result.isValid, isTrue);
  });

  test(
    'accepts a valid saved address without coordinates for regular delivery',
    () {
      final result = DeliveryAddressValidator.validate(address());
      expect(result.isValid, isTrue);
    },
  );
}
